
#Grab json
$JsonConfig = Get-Content ".\config.json" | ConvertFrom-Json
$MainConfig = $JsonConfig.mainConfig

#Disk configuration \ chia exe
$temporaryFolder = $MainConfig.temporaryFolder
#no coalescing operator in ps 5.1
$secondaryTemporaryFolder;
if ($MainConfig.secondaryTemporaryFolder -eq "") {
    $secondaryTemporaryFolder = $temporaryFolder
}
else {
    $secondaryTemporaryFolder = $MainConfig.secondaryTemporaryFolder
}
$finalDisksWhiteList = $MainConfig.plotDisksWhiteList
$finalDisksBlackList = $MainConfig.plotDisksBlacklist #Add system and temporary volume

if ($finalDisksWhiteList.Length -gt 0) {
    [string[]] $finalDisks = (Get-WmiObject win32_logicaldisk | Where-Object { $finalDisksWhiteList.Contains($_.DeviceID) } | ForEach-Object { $_.DeviceID })
}
else {
    [string[]] $finalDisks = (Get-WmiObject win32_logicaldisk | Where-Object { -not $finalDisksBlackList.Contains($_.DeviceID) } | ForEach-Object { $_.DeviceID })
}
$plotSize = $MainConfig.plotSize
$tempPlotSize = $MainConfig.tempPlotSize
$chiaArgs = $MainConfig.chiaArgs
[int32]$TempDiskFreeSpaceInGB = ((Get-Volume -FilePath $temporaryFolder).SizeRemaining / (1024 * 1024 * 1024))
$maxConcurrentPlots = $MainConfig.maxConcurrentPlots
[int32]$TimeOut = $MainConfig.timeout #seconds
$MainFolder = $MainConfig.chiaBlockChainFolder + "\*"
$MainFolderPath = $MainConfig.chiaBlockChainFolder
[System.Array]$appVersions = Get-Item -Path $MainFolder | Where-Object { $_.GetType().Name -eq "DirectoryInfo" -and $_.Name -match '\d' } | ForEach-Object { $_.Name }
[string[]]$latestApp = ($appVersions | Sort-Object -Descending)
$ChiaExecutable = $MainFolderPath + "\" + "$latestApp\resources\app.asar.unpacked\daemon\chia.exe"
$ChiaAddArgs = $MainConfig.chiaAdd


#----------PRECONDITIONS
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
#---------END PRECONDITIONS