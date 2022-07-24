Import-Module AzureAD

#Username and PW for Login
$Credential = Get-Credential

Connect-AzureAD -Credential $Credential

#Are we connected?
Get-AzureADUser

#Create a password profile
$PasswordProfile = New-Object -TypeName Microsoft.Open.AzureAD.Model.PasswordProfile
$PasswordProfile.Password = "P@ssw0rdMS"

New-AzureADUser -DisplayName "Andrei Pintica" -PasswordProfile $PasswordProfile -UserPrincipalName "Andrei.Pintica@APILAB" -AccountEnabled $true -MailNickName "AndreiPintica"

Get-AzureADUser -Filter "Displayname eq 'Andrei'"

New-AzureADGroup -DisplayName "Store" -MailEnabled $false -SecurityEnabled $true -MailNickName "Store"

Get-AzureADGroup -Filter "DisplayName eq 'Store'"

Get-AzureADUser -Filter "Displayname eq 'Andrei Pintica'"

Add-AzureADGroupMember -ObjectId "e0179643-72bd-476e-a0a5-c78d09cb231f" -RefObjectId "0e23bdf9-a3cb-48e8-8b4a-cfd64e9f207c" #RefObjectID = User; ObjectId = Gruppe

Get-AzureADGroup -Filter "DisplayName eq 'Store'"

Get-AzureADUserMembership  -ObjectId "0e23bdf9-a3cb-48e8-8b4a-cfd64e9f207c" #RefObjectID = User;

Get-AzureADGroupMember -ObjectId "e0179643-72bd-476e-a0a5-c78d09cb231f" #ObjectId = Gruppe

#Another way
$domain = "apilab"

#Find an existing user
Get-AzureADUser -SearchString "FR"

Get-AzureADUser -Filter "State eq 'SO'"

Get-AzureADUser -Filter "Displayname eq 'Fred Prefect'" | Select-Object Displayname, State, Department

#Creating a new user
$user = @{
    City = "Bucharest"
    Country = "Romania"
    Department = "Information Technology"
    DisplayName = "Andrei Pintica"
    GivenName = "API"
    JobTitle = "Azure Administrator"
    UserPrincipalName = "andrei.pintica@$domain"
    PasswordProfile = $PasswordProfile
    PostalCode = "041345"
    State = "RO"
    StreetAddress = "Secret"
    Surname = "Pintica"
    TelephoneNumber = "xxxxxxxxxxxxx"
    MailNickname = "AndreiPintica"
    AccountEnabled = $true
    UsageLocation = "CH"
}

$newUser = New-AzureADUser @user

$newUser | Format-List

Get-AzureADUser -Filter "Displayname eq 'Andrei Pintica'" | Select-Object Displayname, State, Department