#Run the following command to install the AzureAD Sync module:
Import-Module ADSync
#Next lets review the current intervals AzureAD Connect uses to sync by running the following command
Get-ADSyncScheduler

#Note: The report should show intervals of 30 minute syncs and a sync policy type of Delta. A sync policy type of Initial is usually shown after AzureAD Connect's initial sync but can also be forced as detailed in the next step.

#Run the following command to initialize the AzureAD Sync immediately
Start-ADSyncSyncCycle -PolicyType Delta

#Note: This will only sync current changes.  Run the following command to force a complete sync but note that the length of sync time would be greatly increased.

Start-ADSyncSyncCycle -PolicyType Initial
