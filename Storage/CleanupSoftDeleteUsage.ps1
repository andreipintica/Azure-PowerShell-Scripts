###
## DISCLAIMER : This is a sample and is provided as is with no warranties express or implied.
##
## The RemoveSoftDeletedBlobs switch will cause changes to the storage account. Please ensure you test and
## understand all implications before running this against critical data.
##
#
#
# USAGE
# -------------------  Delete
#./CleanUpSoftDeleteUsage.ps1 -storage_account_name "mystoreageaccount" -storage_shared_key "mykey" -RemoveSoftDeletedBlobs
#./CleanUpSoftDeleteUsage.ps1 -storage_account_name "mystoreageaccount" -storage_sas_token "mysastoken" -RemoveSoftDeletedBlobs
#
# -------------------  List table with totals only
#./CleanUpSoftDeleteUsage.ps1 -storage_account_name "mystoreageaccount" -storage_shared_key "mykey" 
#./CleanUpSoftDeleteUsage.ps1 -storage_account_name "mystoreageaccount" -storage_sas_token "mysastoken" 
###

[CmdletBinding(DefaultParametersetName="SharedKey")]
param(

  [Parameter(Mandatory=$true, HelpMessage="Storage Account Name")] 
  [String] $storage_account_name,

  [Parameter(Mandatory=$true, HelpMessage="Any one of the two shared access keys", ParameterSetName="SharedKey", Position=1)] 
  [String] $storage_shared_key,
  
  [Parameter(Mandatory=$true, HelpMessage="SAS Token : the GET parameters", ParameterSetName="SASToken", Position=1)] 
  [String] $storage_sas_token,

  [Parameter (Mandatory=$false, HelpMessage="Delete all soft deleted blobs to either reset retention or reclaim space")]
  [Switch] $RemoveSoftDeletedBlobs        
 
)

$containerstats = @()

If ($PsCmdlet.ParameterSetName -eq "SharedKey")
{
        $Ctx = New-AzStorageContext -StorageAccountName $storage_account_name -StorageAccountKey $storage_shared_key
}
Else
{
        $Ctx = New-AzStorageContext -StorageAccountName $storage_account_name -SasToken $storage_sas_token
}

if ($RemoveSoftDeletedBlobs)
{
        Write-Host "NOTE : You have chosen to remove soft deleted blobs. This involves first undeleting and then deleting the blob again." -ForegroundColor Yellow
        Write-Host "           The new delete operation will use the current soft delete policy. If your intent is to release space," -ForegroundColor Yellow
        Write-Host "           you may want to remove any soft delete policy on this storage account first before continuing." -ForegroundColor Yellow
        $resp = Read-Host -Prompt "Continue? (Y/N)"
        if ($resp -inotmatch "^(Y|Yes)$")
        {
                ## Quit now and do no harm
                Write-Host "Stopping here.."
                exit
        }
}
　
$container_continuation_token = $null

do {

        $containers = Get-AzStorageContainer -Context $Ctx -MaxCount 5000 -ContinuationToken $container_continuation_token
        
        $container_continuation_token = $null;
        
        if ($containers -ne $null)
        {
                $container_continuation_token = $containers[$containers.Count - 1].ContinuationToken

                for ([int] $c = 0; $c -lt $containers.Count; $c++)
                {
                        $container = $containers[$c].Name

                        Write-Verbose "Processing container : $container"

                        $total_usage = 0
                        $total_blob_count = 0
                        $soft_delete_usage = 0
                        $soft_delete_count = 0
                
                        $blob_continuation_token = $null
                
                        do {
                        
                                $blobs = Get-AzStorageBlob -Context $Ctx -Container $container -MaxCount 5000 -IncludeDeleted -ContinuationToken $blob_continuation_token

                                $blob_continuation_token = $null;

                                if ($blobs -ne $null)
                                {
                                        $blob_continuation_token = $blobs[$blobs.Count - 1].ContinuationToken

                                        for ([int] $b = 0; $b -lt $blobs.Count; $b++)
                                        {
                                                $total_blob_count++
                                                $total_usage += $blobs[$b].Length
                                                if ($blobs[$b].IsDeleted)
                                                {
                                                    $soft_delete_count++
                                                    $soft_delete_usage += $blobs[$b].Length
                                                    if ($RemoveSoftDeletedBlobs)
                                                    {
                                                        $blobs[$b].ICloudBlob.Undelete()
                                                        $blobs[$b].ICloudBlob.Delete()
                                                    }
                                                }
                                        }

                                        If ($blob_continuation_token -ne $null)
                                        {
                                                Write-Verbose "Blob listing continuation token = {0}".Replace("{0}",$blob_continuation_token.NextMarker)
                                        }
                                }
                        } while ($blob_continuation_token -ne $null)

                        Write-Verbose "Calculated size of $container = $total_usage with soft_delete usage of $soft_delete_usage"
                        
                        $containerstats += [PSCustomObject] @{ 
                                                Name = $container 
                                                TotalBlobCount = $total_blob_count 
                                                TotalBlobUsage = $total_usage 
                                                SoftDeletedBlobCount = $soft_delete_count 
                                                SoftDeletedBlobUsage = $soft_delete_usage 
                                                }
                }
   }
 
   If ($container_continuation_token -ne $null)
   {
                Write-Verbose "Container listing continuation token = {0}".Replace("{0}",$container_continuation_token.NextMarker)
   }

} while ($container_continuation_token -ne $null)


Write-Host "Total container stats"
$containerstats | Format-Table -AutoSize 
