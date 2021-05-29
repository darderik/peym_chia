#Includes
using module .\Classes\PlotterClass.psm1
using module .\Classes\HardDrive.psm1
using module .\ProgressUpdater\DisplayLogic.psm1
Import-Module $PSScriptRoot\Functions\detectChiaPlotters.psm1  -Force
Import-Module $PSScriptRoot\Functions\selectTargetHardDisk.psm1 -Force
Import-Module $PSScriptRoot\Functions\Utilities.psm1 -Force
Import-Module $PSScriptRoot\Functions\cleanupTemporary.psm1 -Force

$curPath = (Get-Item -Path $MyInvocation.MyCommand.Path).DirectoryName
Set-Location $curPath

. .\InitConfig.ps1
$Jobs = New-Object -Type 'Collections.Generic.List[Plotter]'

#Detect eventual running plotters
$detected = DetectChiaPlotters $finalDisks
if (-not ($detected.Count -eq 0 -or $detected.ID -eq 0)) {
    [Collections.Generic.List[Plotter]]$Jobs = $detected
    Write-Host -ForegroundColor DarkGreen "$(Get-Date -Format "dd/MM HH:mm")Detected running plotters."
    Write-Host ($detected | Format-List | Out-String) -ForegroundColor DarkGreen #todo debug print
}

#Cleanup temporary folder
cleanupTemporary($temporaryFolder)

#Main Loop
$isPhase1Over = $null
[string]$Status
do { 
    #Update info on running plotters
    foreach ($curProc in $Jobs.ToArray()) {
        $MainProcess = $curProc.Process
        if ($MainProcess.HasExited) {
            $curProc.Dispose()
            $Jobs.Remove($curProc)
            cleanupTemporary($temporaryFolder)

        }
    }
    #dynamic temporary volume incoming TOBEREVISED
    $temporaryVolumeLabel = (Get-Volume -FilePath $temporaryFolder).DriveLetter + ":"
    $2temporaryVolumeLabel = (Get-Volume -FilePath $secondaryTemporaryFolder).DriveLetter + ":"


    if ($finalDisks[$temporaryVolumeLabel].getProjectedFreeSpace(1GB, 1) -le $global:tempPlotSize) {
        DisplayLogic "Space on temporary disk insufficient. Waiting."
        Start-Sleep -Seconds ($TimeOut / 2)
        continue
    }
    if ($Jobs.Count -ge $maxConcurrentPlots) {
        DisplayLogic "Limit of concurrent plots reached. Waiting."
        Start-Sleep -Seconds ($TimeOut / 2)
        continue
    }

    if ($Jobs.Count -lt 1 -or $isPhase1Over) {
        #no check needed,tempdiskfree is sufficient
        $isPhase1Over = $null
        #Disk selection logic
        [System.String]$hdd = selectTargetHardDisk $finalDisks
        if ($hdd.Length -lt 1) {
            #No hard drive with space
            DisplayLogic "No hard drive with sufficient space. Exiting."
            break
        }
        else {
            if (!(Test-Path "$hdd\ChiaPlots")) {
                New-item -ItemType directory -Path "$hdd\ChiaPlots"
            }
            DisplayLogic "Starting to plot! Hard Disk: $hdd"

            $argsString = $chiaArgs -f $temporaryFolder, $hdd, $secondaryTemporaryFolder

            #Add plot folder
            $AddArgsFormatted = $ChiaAddArgs -f $hdd
            $CommandAddFormatted = "$ChiaExecutable $AddArgsFormatted"
            Invoke-Expression $CommandAddFormatted

            [Plotter]$curPlot = NewPlot $ChiaExecutable $argsString @($finalDisks[$hdd], $finalDisks[$temporaryVolumeLabel], $finalDisks[$2temporaryVolumeLabel])
            if ($null -ne $curPlot) {
                $Jobs.Add($curPlot)
            }
        }
    }
    else {
        #plots running,check if phase 2 started
        $mostRecentPlotLog = $Jobs[$Jobs.Count - 1].LogFile
        if ($null -ne $mostRecentPlotLog -and $mostRecentPlotLog -ne "") {
            $isPhase1Over = Select-String -Path $mostRecentPlotLog -Pattern "phase 2/4"
        }
    }
    DisplayLogic "Plotting. Running plotters $($Jobs.Count)"
    
    Start-Sleep -Seconds $TimeOut
} while (([System.String](selectTargetHardDisk $finalDisks)).Length -gt 0)

Read-Host