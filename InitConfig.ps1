#Grab json
$JsonConfig = Get-Content ".\config.json" | ConvertFrom-Json
$MainConfig = $JsonConfig.mainConfig


$global:DEBUG = $MainConfig.DEBUG


#region HDD Fetching
[string[]]$temporaryFolders = $MainConfig.temporaryFolders

[string]$temporarySecondaryFolder = $MainConfig.temporarySecondaryFolder

$finalDisksWhiteList = $MainConfig.plotDisksWhiteList
$finalDisksBlackList = $MainConfig.plotDisksBlacklist 
$finalDisksBlackList = $finalDisksBlackList + (($temporaryFolders | Select-String -pattern "\w:") | ForEach-Object { $_.Matches[0].Value }) + ($temporarySecondaryFolder | Select-String -pattern "\w:").Matches[0].Value


if ($finalDisksWhiteList.Length -gt 0) {
    $finalDisksStr = (Get-WmiObject win32_logicaldisk | Where-Object { $finalDisksWhiteList.Contains($_.DeviceID) } | ForEach-Object { $_.DeviceID })
}
else {
    $finalDisksStr = (Get-WmiObject win32_logicaldisk | Where-Object { -not $finalDisksBlackList.Contains($_.DeviceID) } | ForEach-Object { $_.DeviceID })
}
#endregion Hdd Fetching

#region Settings
$global:plotSize = $MainConfig.plotSize
$global:tempPlotSize = $MainConfig.tempPlotSize
$chiaArgs = $MainConfig.chiaArgs
$maxConcurrentPlots = $MainConfig.maxConcurrentPlots
$maxPlotsPerDisk = $MainConfig.maxPlotsPerDisk
[int32]$TimeOut = $MainConfig.timeout #seconds
$MainFolder = $MainConfig.chiaBlockChainFolder + "\*"
$MainFolderPath = $MainConfig.chiaBlockChainFolder
[System.Array]$appVersions = Get-Item -Path $MainFolder | Where-Object { $_.GetType().Name -eq "DirectoryInfo" -and $_.Name -match '\d' } | ForEach-Object { $_.Name }
[string[]]$latestApp = ($appVersions | Sort-Object -Descending)
$ChiaExecutable = $MainFolderPath + "\" + "$latestApp\resources\app.asar.unpacked\daemon\chia.exe"
$ChiaAddArgs = $MainConfig.chiaAdd
$global:filterTempDisks = $MainConfig.filterTempDisks
#endregion Settings

#region HDD Objects setup
$DisksObjs = @{}


#final hard disks
foreach ($item in ($finalDisksStr)) {
    $newHD = [HardDrive]::new($item, 0)
    $DisksObjs.Add($newHD.Label, $newHD)
}

#temporary 1 hard disks
$temp1 = $temporaryFolders
$temporaryFoldersList = New-Object 'System.Collections.Generic.List[HardDrive]'
foreach ($item in ($temp1)) {
    $newHD = [HardDrive]::new($item, 1)
    $newHD.TempPath = $item
    $temporaryFoldersList.Add($newHD)
    $DisksObjs.Add($newHD.Label, $newHD)
}#Create list
$cur1Temporary = [HardDriveNode]::new($temporaryFoldersList.ToArray(), 8) #HEAD

#temporary 2 hard disks, todo introduce secondary folders array
$temp2 = @($temporarySecondaryFolder)
foreach ($item in $temp2) {
    $newHD = [HardDrive]::new($item, 2)
    $DisksObjs.Add($newHD.Label, $newHD)
}
[hashtable]$global:finalDisks = $DisksObjs
#endregion HDD Objects setup



#region PRECONDITIONS
#Create streams folder
if (-not(Test-Path ".\Streams")) {
    mkdir Streams
}

if (-not (Test-Path -Path $ChiaExecutable)) {
    Write-Host("No chia exe found in path $ChiaExecutable") -ForegroundColor "Red"
    exit
}
#Prepare temporaries path 
foreach ($tmpPath in $temporaryFolders) {
    if (!(Test-Path $tmpPath)) {
        Write-Host "Creating temporary folder at $tmpPath"
        New-Item -ItemType directory -Path $tmpPath
    }
}
if ($secondaryTemporaryFolder -ne "" -and $null -ne $secondaryTemporaryFolder ) {
    #Prepare 2nd temporary path 
    if (!(Test-Path $secondaryTemporaryFolder)) {
        Write-Host "Creating temporary folder at $secondaryTemporaryFolder"
        New-Item -ItemType directory -Path $secondaryTemporaryFolder
    }
}
#endregion PRECONDITIONS

#region Cleaning
foreach ($fld in $temporaryFolders) {
    if (Test-Path $fld) {
        cleanupTemporary($fld)
    }
}
#endregion Cleaning
