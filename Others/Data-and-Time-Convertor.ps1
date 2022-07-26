#Load required libraries
Add-Type -AssemblyName PresentationFramework, PresentationCore, WindowsBase, System.Windows.Forms, System.Drawing 

[xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        
        Title="Date and Time Converter V1.0 - Manual" Height="525" Width="575">
    <Grid>
        <Button x:Name="launchButton" Content="Launch" HorizontalAlignment="Right" Margin="0,0,10,10" VerticalAlignment="Bottom" Width="75" Height="23"/>
        <Image x:Name="manual" Margin="10,10,10,42"/>
        <Label x:Name="url"  HorizontalAlignment="Left" Margin="10,0,0,10" VerticalAlignment="Bottom" FontSize='14' ToolTip='vmware'>
            <Hyperlink NavigateUri="http://vcloud-lab.com">http://vcloud-lab.com</Hyperlink>
        </Label>
    </Grid>
</Window>
"@

#Read the form
$Reader = (New-Object System.Xml.XmlNodeReader $xaml) 
$Form = [Windows.Markup.XamlReader]::Load($reader) 

#AutoFind all controls
$xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { 
  New-Variable  -Name $_.Name -Value $Form.FindName($_.Name) -Force 
}
$uri = {[system.Diagnostics.Process]::start('http://www.vmware.com')}
$url.Add_PreviewMouseDown($uri)
$manual.Source = 'ManPage.jpg'

$launchButton.Add_Click({
    $form.Close()
    [xml]$xaml = @"
<Window 
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:WpfApp1"
        Title="Date and Time Converter V1.0 - http://github.com/andreipintica" Height="175" Width="850" ResizeMode="NoResize" Topmost="True">
    
    <Grid>
    <Label Content="Select Zone:" HorizontalAlignment="Left" Margin="10,10,0,0" VerticalAlignment="Top" Width="77"/>
        <ComboBox x:Name="comboBoxTimeZoneLists" HorizontalAlignment="Left" Margin="10,41,0,0" Width="186" Height="23" VerticalAlignment="Top"/>
        <Button x:Name="buttonStop" Content="Stop or Change" HorizontalAlignment="Left" Margin="92,10,0,0" VerticalAlignment="Top" Width="103" Height="23"/>
        <RadioButton x:Name="radioButtonBox1" Content="" HorizontalAlignment="Left" Margin="10,0,0,56" VerticalAlignment="Bottom" IsChecked="true" />
        <RadioButton x:Name="radioButtonBox2" Content="Eastern Standard Time" HorizontalAlignment="Left" Margin="10,0,0,33" VerticalAlignment="Bottom"/>
        <RadioButton x:Name="radioButtonBox3" Content="GMT Standard Time" HorizontalAlignment="Left" Margin="10,0,0,10" VerticalAlignment="Bottom"/>
        
        <Rectangle Fill="orange" Margin="200,10,0,17" HorizontalAlignment="Left" Width="205"/>
        <GroupBox x:Name="group1" Header="Checking TimeZone" HorizontalAlignment="Left" Height="108" Margin="201,10,0,0" VerticalAlignment="Top" Width="203">
            <Grid>
                <TextBox x:Name="textBoxGroup1Hours" HorizontalAlignment="Left" Height="38" Margin="1,0,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="41" FontFamily="Consolas" FontSize="26" MaxLength="2"/>
                <Label Content=":" HorizontalAlignment="Left" Margin="42,2,0,0" VerticalAlignment="Top" Height="36" FontSize="18"/>
                <TextBox x:Name="textBoxGroup1Minutes" HorizontalAlignment="Left" Height="38" Margin="56,0,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="41" FontFamily="Consolas" FontSize="26" MaxLength="2"/>
                <Label Content=":" HorizontalAlignment="Left" Margin="97,0,0,0" VerticalAlignment="Top" Height="38" FontSize="18"/>
                <TextBox x:Name="textBoxGroup1Seconds" HorizontalAlignment="Left" Height="24" Margin="111,12,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="30" FontFamily="Consolas" FontSize="16" IsReadOnly="True"/>
                <DatePicker x:Name="datePickerGroup1Default" HorizontalAlignment="Left" Margin="1,46,0,0" VerticalAlignment="Top" Width="134"/>
                <RadioButton x:Name="radioButtonGroup1AM" Content="AM" HorizontalAlignment="Left" Margin="146,0,0,0" VerticalAlignment="Top" Width="45"/>
                <RadioButton x:Name="radioButtonGroup1PM" Content="PM" HorizontalAlignment="Left" Margin="146,23,0,0" VerticalAlignment="Top" Width="44" />
                <Button x:Name="buttonGroup1Start" Content="Start" HorizontalAlignment="Left" Margin="139,46,0,0" VerticalAlignment="Top" Width="51" Height="23" IsEnabled="False"/>
            </Grid>
        </GroupBox>
        
        <Rectangle Fill="greenyellow" Margin="414,10,208,17" HorizontalAlignment="Left" Width="205"/>
        <GroupBox x:Name="group2" Header="Eastern Standard Time" HorizontalAlignment="Left" Height="108" Margin="415,10,0,0" VerticalAlignment="Top" Width="203">
            <Grid>
                <TextBox x:Name="textBoxGroup2Hours" HorizontalAlignment="Left" Height="38" Margin="1,0,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="41" FontFamily="Consolas" FontSize="26" IsReadOnly="True" MaxLength="2"/>
                <Label Content=":" HorizontalAlignment="Left" Margin="42,2,0,0" VerticalAlignment="Top" Height="36" FontSize="18"/>
                <TextBox x:Name="textBoxGroup2Minutes" HorizontalAlignment="Left" Height="38" Margin="56,0,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="41" FontFamily="Consolas" FontSize="26" IsReadOnly="True" MaxLength="2"/>
                <Label Content=":" HorizontalAlignment="Left" Margin="97,0,0,0" VerticalAlignment="Top" Height="38" FontSize="18"/>
                <TextBox x:Name="textBoxGroup2Seconds" HorizontalAlignment="Left" Height="24" Margin="111,12,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="30" FontFamily="Consolas" FontSize="16" IsReadOnly="True"/>
                <DatePicker x:Name="datePickerGroup2Default" HorizontalAlignment="Left" Margin="1,46,0,0" VerticalAlignment="Top" Width="134"/>
                <RadioButton x:Name="radioButtonGroup2AM" Content="AM" HorizontalAlignment="Left" Margin="146,0,0,0" VerticalAlignment="Top" Width="45"/>
                <RadioButton x:Name="radioButtonGroup2PM" Content="PM" HorizontalAlignment="Left" Margin="146,23,0,0" VerticalAlignment="Top" Width="44" />
                <!-- <Button x:Name="buttonGroup2Start" Content="Start" HorizontalAlignment="Left" Margin="139,46,0,0" VerticalAlignment="Top" Width="51" Height="23" IsEnabled="False"/> -->
            </Grid>
        </GroupBox>
        <Rectangle Fill="cyan" HorizontalAlignment="Right" Margin="5,10,5,17" Width="208"/>
        <GroupBox x:Name="group3" Header="GMT Standard Time" HorizontalAlignment="Left" Height="108" Margin="623,10,0,0" VerticalAlignment="Top" Width="203">
            <Grid>
                <TextBox x:Name="textBoxGroup3Hours" HorizontalAlignment="Left" Height="38" Margin="1,0,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="41" FontFamily="Consolas" FontSize="26" IsReadOnly="True" MaxLength="2"/>
                <Label Content=":" HorizontalAlignment="Left" Margin="42,2,0,0" VerticalAlignment="Top" Height="36" FontSize="18"/>
                <TextBox x:Name="textBoxGroup3Minutes" HorizontalAlignment="Left" Height="38" Margin="56,0,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="41" FontFamily="Consolas" FontSize="26" IsReadOnly="True" MaxLength="2"/>
                <Label Content=":" HorizontalAlignment="Left" Margin="97,0,0,0" VerticalAlignment="Top" Height="38" FontSize="18"/>
                <TextBox x:Name="textBoxGroup3Seconds" HorizontalAlignment="Left" Height="24" Margin="111,12,0,0" TextWrapping="Wrap" Text="88" VerticalAlignment="Top" Width="30" FontFamily="Consolas" FontSize="16" IsReadOnly="True"/>
                <DatePicker x:Name="datePickerGroup3Default" HorizontalAlignment="Left" Margin="1,46,0,0" VerticalAlignment="Top" Width="134"/>
                <RadioButton x:Name="radioButtonGroup3AM" Content="AM" HorizontalAlignment="Left" Margin="146,0,0,0" VerticalAlignment="Top" Width="45"/>
                <RadioButton x:Name="radioButtonGroup3PM" Content="PM" HorizontalAlignment="Left" Margin="146,23,0,0" VerticalAlignment="Top" Width="44" />
                <!-- <Button x:Name="buttonGroup3Start" Content="Start" HorizontalAlignment="Left" Margin="139,46,0,0" VerticalAlignment="Top" Width="51" Height="23" IsEnabled="False"/> -->
            </Grid>
        </GroupBox>
    </Grid>
</Window>
"@

    #Read the form
    $Reader = (New-Object System.Xml.XmlNodeReader $xaml) 
    $Form = [Windows.Markup.XamlReader]::Load($reader) 

    #AutoFind all controls
    $xaml.SelectNodes("//*[@*[contains(translate(name(.),'n','N'),'Name')]]")  | ForEach-Object { 
    New-Variable  -Name $_.Name -Value $Form.FindName($_.Name) -Force 
    }

    $allTimeZones = [System.TimeZoneInfo]::GetSystemTimeZones()
    $currentTimeZone = [System.TimeZoneInfo]::Local

    #Add Time Zone Index to ComboBox 
    $comboBoxTimeZoneLists.ItemsSource = $allTimeZones.Displayname
    $comboBoxTimeZoneLists.SelectedIndex = $comboBoxTimeZoneLists.items.IndexOf($currentTimeZone.DisplayName)

    function Show-MessageBox {   
        param (   
        [string]$Message = "Show user friendly Text Message",   
        [string]$Title = 'Title here',   
        [ValidateRange(0,5)]   
        [Int]$Button = 0,   
        [ValidateSet('None','Hand','Error','Stop','Question','Exclamation','Warning','Asterisk','Information')]   
        [string]$Icon = 'Error'   
        )   
        #Note: $Button is equl to [System.Enum]::GetNames([System.Windows.Forms.MessageBoxButtons])   
        #Note: $Icon is equl to [System.Enum]::GetNames([System.Windows.Forms.MessageBoxIcon])   
        $MessageIcon = [System.Windows.Forms.MessageBoxIcon]::$Icon
        [System.Windows.Forms.MessageBox]::Show($Message,$Title,$Button,$MessageIcon)
    }  

    function Convertto-GroupTimes {
        param 
        (
            $SourceGroup,
            $DestinationGroup
        )
        
        $sourceChilds = $SourceGroup.Content.Children
        $sourceHour = $sourceChilds | Where-Object {$_.Name -match 'Hours'}
        $sourceminute = $sourcechilds | Where-Object {$_.Name -match 'Minutes'}
        $sourcedatePicker = $sourcechilds | Where-Object {$_.Name -match 'datePicker'}
        $sourceAM = $sourcechilds | Where-Object {$_.Name -cmatch 'AM'}
        #$sourcePM = $sourcechilds | Where-Object {$_.Name -cmatch 'PM'}

        if ($sourceAM.isChecked -eq $true) {
            $sourceAMPM = 'AM'
        }
        else {
            $sourceAMPM = 'PM'
        }
        $stringSourceDateTime = "{0} {1}:{2} {3}" -f $sourcedatePicker.Text, $sourcehour.Text, $sourceminute.Text, $sourceAMPM
        $dateTimeFormat = [datetime]$stringSourceDateTime
        
        $destinationTimeZoneInfo = $allTimeZones | Where-Object {$_.StandardName -eq $DestinationGroup.Header}
        $destChilds = $DestinationGroup.Content.Children 

        $baseUniversalTime = $dateTimeFormat.ToUniversalTime()
        $convertedNewDate = $baseUniversalTime + $destinationTimeZoneInfo.BaseUtcOffset
        $isSummer = (Get-Date).IsDaylightSavingTime()
        
        if ($isSummer -and $destinationTimeZoneInfo.SupportsDaylightSavingTime)
        {
            $convertedNewDate = $dateTimeGroup1.AddHours(1)
        }
        
        $destHour = $destChilds | Where-Object {$_.Name -match 'Hours'}
        $destminute = $destchilds | Where-Object {$_.Name -match 'Minutes'}
        $destdatePicker = $destchilds | Where-Object {$_.Name -match 'datePicker'}
        $destaM = $destchilds | Where-Object {$_.Name -cmatch 'AM'}
        $destpM = $destchilds | Where-Object {$_.Name -cmatch 'PM'}

        $desthour.Text = $convertedNewDate.Hour.ToString('00')
        $destminute.Text = $convertedNewDate.Minute.ToString('00')
        $destdatePicker.Text = $convertedNewDate
        $destdayAMPM = $convertedNewDate.DateTime.Substring(($convertedNewDate.DateTime.Length - 2), 2)
        switch ($destdayAMPM) {
            'AM' {
                $destaM.IsChecked = $true
                $destpM.IsChecked = $false
                break
            }
            'PM' {
                $destaM.IsChecked = $false
                $destpM.IsChecked = $true
                break
            }
        }
    }

    function ConvertTo-DifferentTimeZone {
        param 
        (
            $Groups
        )
        #$group1Datetime = "{0} {1}:{2}" -f $datePickerGroup1Default.text, $textBoxGroup1Hours.text, $textBoxGroup1Minutes.Text
        $isSummer = (Get-Date).IsDaylightSavingTime()
        $changedTimeZoneGroup1 = $allTimeZones | Where-Object {$_.StandardName -eq $Groups.Header} #change to where-object ($_.Displayname -eq $comboBoxTimeZoneLists.SelectedItem)
        $dateTime = [DateTime]::UtcNow + $ChangedTimeZoneGroup1.BaseUtcOffset
        if ($isSummer -and $changedTimeZoneGroup1.SupportsDaylightSavingTime)
        {
            $dateTimeGroup1 = $dateTimeGroup1.AddHours(1)
        }
        $dateTime
    }

    function Update-TimeInfoGroup
    {
        param
        (
            $Seconds, 
            $Minutes, 
            $Hours,
            $AM,
            $PM,
            $Date,
            $Groups,
            [switch]$Now
        )
        
        $isSummer = (Get-Date).IsDaylightSavingTime()
        
        If ($Now -eq $true) {
            #Now
            $dateTime = [DateTime]::Now
            if ($isSummer -and $dateTime.SupportsDaylightSavingTime())
            {
                $dateTime = $dateTime.AddHours(1)
            }
        }
        else {
            #UtcNow
            $dateTime = ConvertTo-DifferentTimeZone -Groups $Groups
        }
        $dayAMPM = $dateTime.ToString('tt')
        $Seconds.Text = $dateTime.Second.ToString("00")
        $Minutes.Text = $dateTime.Minute.ToString("00")
        $Hours.Text = $dateTime.Hour.ToString("00")
        
        switch ($dayAMPM) {
            'AM' {
                $AM.isChecked = $true
                $PM.isChecked = $false
                break
            }
            'PM' {
                $AM.isChecked = $false
                $PM.isChecked = $True
                break
            }
        }
        $Date.text = $dateTime
    }

    function Set-TimeForGroup {
        param 
        (
            $Groups
        )
            if ($Groups.Header -eq $currentTimeZone.StandardName) { #$Groups.Header change to $comboBoxTimeZoneLists.SelectedItem and $currentTimeZone.DisplayName
            $tickNow = $true
        }
        else {
            $tickNow = $false
        }
        $ticknow
    }

    function Set-Group1Item {
        param 
        (
            $Groups
        )
        $selectedZone = $allTimeZones | where-object {$_.Displayname -eq $comboBoxTimeZoneLists.SelectedItem} 
        $group1.Header = $selectedZone.StandardName
        $radioButtonBox1.Content = $group1.Header

        $now = Set-TimeForGroup -Groups $group1
        $updateGroup1Parameters = @{
            Seconds = $textBoxGroup1Seconds
            Minutes = $textBoxGroup1Minutes
            Hours = $textBoxGroup1Hours
            AM = $radioButtonGroup1AM
            PM = $radioButtonGroup1PM
            date = $datePickerGroup1Default
            Now = $now
            Groups = $group1
        }
        Update-TimeInfoGroup @updateGroup1Parameters
    }

    Set-Group1Item -Groups group1

    $Global:Timer = new-object System.Windows.Threading.DispatcherTimer
    $Global:Timer.Interval = [TimeSpan]'0:0:1.0'

    function Start-Timer 
    {
        $Global:Timer.Add_Tick.Invoke({
            $now1 = Set-TimeForGroup -Groups $group1
            $updateGroup1Parameters = @{
                Seconds = $textBoxGroup1Seconds
                Minutes = $textBoxGroup1Minutes
                Hours = $textBoxGroup1Hours
                AM = $radioButtonGroup1AM
                PM = $radioButtonGroup1PM
                date = $datePickerGroup1Default
                Now = $now1
                Groups = $group1
            }
            Update-TimeInfoGroup @updateGroup1Parameters

            $now2 = Set-TimeForGroup -Groups $group2
            $updateGroup2Parameters = @{
                Seconds = $textBoxGroup2Seconds
                Minutes = $textBoxGroup2Minutes
                Hours = $textBoxGroup2Hours
                AM = $radioButtonGroup2AM
                PM = $radioButtonGroup2PM
                date = $datePickerGroup2Default
                Now = $now2
                Groups = $group2
            }
            Update-TimeInfoGroup @updateGroup2Parameters

            $now3 = Set-TimeForGroup -Groups $group3
            $updateGroup3Parameters = @{
                Seconds = $textBoxGroup3Seconds
                Minutes = $textBoxGroup3Minutes
                Hours = $textBoxGroup3Hours
                AM = $radioButtonGroup3AM
                PM = $radioButtonGroup3PM
                date = $datePickerGroup3Default
                Now = $now3
                Groups = $group3
            }
            Update-TimeInfoGroup @updateGroup3Parameters
        })
        $Global:Timer.IsEnabled = $true
        $Global:Timer.Start()
        $buttonGroup1Start.IsEnabled = $false
        $textBoxGroup1Hours.IsReadOnly = $true
        $textBoxGroup1Minutes.IsReadOnly = $true
    }
    Start-Timer

    function Stop-Timer 
    {
        $Global:Timer.IsEnabled = $false
        $Global:Timer.Stop()
        $buttonGroup1Start.IsEnabled = $true
        $textBoxGroup1Hours.IsReadOnly = $false
        $textBoxGroup1Minutes.IsReadOnly = $false
    }

    #Timezone change
    $comboBoxTimeZoneLists.Add_SelectionChanged({
        if ($radioButtonBox1.IsChecked -eq $true) {
            Set-Group1Item -Groups $group1
        }
        elseif ($radioButtonBox2.IsChecked -eq $true) {
            $selectedZone = $allTimeZones | where-object {$_.Displayname -eq $comboBoxTimeZoneLists.SelectedItem} 
            $group2.Header = $selectedZone.StandardName
            $radioButtonBox2.Content = $group2.Header

            $now = Set-TimeForGroup -Groups $group2
            $updateGroup2Parameters = @{
                Seconds = $textBoxGroup2Seconds
                Minutes = $textBoxGroup2Minutes
                Hours = $textBoxGroup2Hours
                AM = $radioButtonGroup2AM
                PM = $radioButtonGroup2PM
                date = $datePickerGroup2Default
                Now = $now
                Groups = $group2
            }
            Update-TimeInfoGroup @updateGroup2Parameters
        }
        elseif ($radioButtonBox3.IsChecked -eq $true) {
            $selectedZone = $allTimeZones | where-object {$_.Displayname -eq $comboBoxTimeZoneLists.SelectedItem} 
            $group3.Header = $selectedZone.StandardName
            $radioButtonBox3.Content = $group3.Header

            $now = Set-TimeForGroup -Groups $group3
            $updateGroup2Parameters = @{
                Seconds = $textBoxGroup2Seconds
                Minutes = $textBoxGroup2Minutes
                Hours = $textBoxGroup2Hours
                AM = $radioButtonGroup2AM
                PM = $radioButtonGroup2PM
                date = $datePickerGroup2Default
                Now = $now
                Groups = $group2
            }
        }
    })

    function Set-Hour {
        param (
            $Textboxhours,
            $RadioButtonAM,
            $RadioButtonPM
        )
        $Textboxhours.Text = [int]$Textboxhours.Text
        if ($Textboxhours.Text -in 0..11) {
            $RadioButtonAM.IsChecked = $true
            $RadioButtonPM.IsChecked = $false
        }
        elseif ($Textboxhours.Text -in 12..23) {
            $RadioButtonAM.IsChecked = $false
            $RadioButtonPM.IsChecked = $true
        }
        else {
            $Textboxhours.Text = 13
            $RadioButtonAM.IsChecked = $false
            $RadioButtonPM.IsChecked = $true
            Show-MessageBox -Message 'Provided hours should be between digit 1-24' -Title 'Hours problem'| Out-Null
        }
        $Textboxhours.Text = $Textboxhours.Text.PadLeft(2,'0')
    }

    #Change Group Hours Values
    $textBoxGroup1Hours.Add_LostFocus({
        Set-Hour -Textboxhours $textBoxGroup1Hours -RadioButtonAM $radioButtonGroup1AM -RadioButtonPM $radioButtonGroup1PM
    })

    #Change Group Minutes Values
    $textBoxGroup1Minutes.Add_LostFocus({
        Set-Hour -Textboxhours $textBoxGroup1Hours -RadioButtonAM $radioButtonGroup1AM -RadioButtonPM $radioButtonGroup1PM
    })

    #Manage Group1 Am and Pm
    $radioButtonGroup1AM.Add_Checked({
        if (($radioButtonGroup1AM.IsChecked -eq $true) -and ($textBoxGroup1Hours.Text -in 12..23)) {
            $textBoxGroup1Hours.Text = ($textBoxGroup1Hours.Text - 12).ToString('00')
        }
    })

    $radioButtonGroup1PM.Add_Checked({
        if (($radioButtonGroup1PM.IsChecked -eq $true) -and ($textBoxGroup1Hours.Text -in 0..11)) {
            $textBoxGroup1Hours.Text = (12 + $textBoxGroup1Hours.Text).ToString('00')
        }
    })

    #Sync 3 Radiobuttons with Combobox
    function Set-Combobox {
        param 
        (
            $RadioBox
        )
        $currentRadioBoxContent = $allTimeZones | Where-Object {$_.StandardName -eq $RadioBox.content}
        $comboBoxTimeZoneLists.SelectedIndex = $comboBoxTimeZoneLists.items.IndexOf($currentRadioBoxContent.DisplayName)
    }

    $radioButtonBox1.Add_Checked({
        if ($radioButtonBox1.IsChecked -eq $true) {
            Set-Combobox -Radiobox $radioButtonBox1
        }
    })

    $radioButtonBox2.Add_Checked({
        if ($radioButtonBox2.IsChecked -eq $true) {
            Set-Combobox -Radiobox $radioButtonBox2
            #Convertto-GroupTimes -SourceGroup $group1 -DestinationGroup $group2
        }
    })

    $radioButtonBox3.Add_Checked({
        if ($radioButtonBox3.IsChecked -eq $true) {
            Set-Combobox -Radiobox $radioButtonBox3
            #Convertto-GroupTimes -SourceGroup $group1 -DestinationGroup $group3
        }
    })

    #Stop click
    $buttonStop.Add_Click({
        Stop-Timer
        Convertto-GroupTimes -SourceGroup $group1 -DestinationGroup $group2
        Convertto-GroupTimes -SourceGroup $group1 -DestinationGroup $group3
    })

    #Start click
    $buttonGroup1Start.Add_Click({
        Start-Timer
    })

    #Closing argument
    $Form.Add_Closing({
        $Global:Timer.IsEnabled = $false
        $Global:Timer.Stop()
    })



    #Mandetory last line of every script to load form
    [void]$Form.ShowDialog()

}) #$launchButton.Add_Click

[void]$Form.ShowDialog()