#Grab json
$JsonConfig = Get-Content ".\config.json" | ConvertFrom-Json
$MainConfig = $JsonConfig.mainConfig


$global:DEBUG = $MainConfig.DEBUG


#region HDD Fetching
$temporaryFolder = $MainConfig.temporaryFolder
[string]$secondaryTemporaryFolder;
if ($MainConfig.temporarySecondaryFolder -eq "") {
    $secondaryTemporaryFolder = $temporaryFolder
}
else {
    $secondaryTemporaryFolder = $MainConfig.temporarySecondaryFolder
}

$finalDisksWhiteList = $MainConfig.plotDisksWhiteList
$finalDisksBlackList = $MainConfig.plotDisksBlacklist 
$finalDisksBlackList = $finalDisksBlackList + ($temporaryFolder | Select-String -pattern "\w:").Matches[0].Value + ($secondaryTemporaryFolder | Select-String -pattern "\w:").Matches[0].Value

if ($finalDisksWhiteList.Length -gt 0) {
    $finalDisksStr = (Get-WmiObject win32_logicaldisk | Where-Object { $finalDisksWhiteList.Contains($_.DeviceID) } | ForEach-Object { $_.DeviceID })
}
else {
    $finalDisksStr = (Get-WmiObject win32_logicaldisk | Where-Object { -not $finalDisksBlackList.Contains($_.DeviceID) } | ForEach-Object { $_.DeviceID })
}
[int32]$TempDiskFreeSpaceInGB = ((Get-Volume -FilePath $temporaryFolder).SizeRemaining / 1GB)
#endregion Hdd Fetching


$global:plotSize = $MainConfig.plotSize
$global:tempPlotSize = $MainConfig.tempPlotSize
$chiaArgs = $MainConfig.chiaArgs
$maxConcurrentPlots = $MainConfig.maxConcurrentPlots
[int32]$TimeOut = $MainConfig.timeout #seconds
$MainFolder = $MainConfig.chiaBlockChainFolder + "\*"
$MainFolderPath = $MainConfig.chiaBlockChainFolder
[System.Array]$appVersions = Get-Item -Path $MainFolder | Where-Object { $_.GetType().Name -eq "DirectoryInfo" -and $_.Name -match '\d' } | ForEach-Object { $_.Name }
[string[]]$latestApp = ($appVersions | Sort-Object -Descending)
$ChiaExecutable = $MainFolderPath + "\" + "$latestApp\resources\app.asar.unpacked\daemon\chia.exe"
$ChiaAddArgs = $MainConfig.chiaAdd
$global:filterTempDisks = $MainConfig.filterTempDisks

#region HDD Objects setup
$DisksObjs = @{}

#dynamic hard disks will be introduced

#target hard disks
foreach ($item in ($finalDisksStr)) {
    $newHD = [HardDrive]::new($item, 0)
    $DisksObjs.Add($newHD.Label, $newHD)
}

#temporary 1 hard disks
$temp1 = @($temporaryFolder)
foreach ($item in ($temp1)) {
    $newHD = [HardDrive]::new($item, 1)
    $DisksObjs.Add($newHD.Label, $newHD)
}

#temporary 2 hard disks
$temp2 = @($secondaryTemporaryFolder)
foreach ($item in ($temp2)) {
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
#Prepare temporary path 
if (!(Test-Path $temporaryFolder)) {
    Write-Host "Creating temporary folder at $temporaryFolder"
    New-Item -ItemType directory -Path $temporaryFolder
}
if ($secondaryTemporaryFolder -ne "" -and $null -ne $secondaryTemporaryFolder ) {
    #Prepare 2nd temporary path 
    if (!(Test-Path $secondaryTemporaryFolder)) {
        Write-Host "Creating temporary folder at $secondaryTemporaryFolder"
        New-Item -ItemType directory -Path $secondaryTemporaryFolder
    }
}
else {
    $secondaryTemporaryFolder = $temporaryFolder
}
#endregion PRECONDITIONS