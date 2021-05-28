using module ..\Classes\PlotterClass.psm1
function DetectChiaPlotters($disks) {
    $Jobs = New-Object 'System.Collections.Generic.List[Plotter]';
    
    #search streams directory()
    $childItems = Get-ChildItem -Directory -Path ".\Streams" 
    foreach ($folder in $childItems) {
        $GUID = $folder.Name 
        $MainStream = Get-Item -Path ".\Streams\$GUID\Chia-Plot-$GUID.Log"  -ErrorAction SilentlyContinue
        $StartTime = $MainStream.CreationTime
        $GUID_ID_DSK = (Get-Content -Path ".\Streams\$GUID\Guid-ID.txt" -ErrorAction SilentlyContinue).Split('|') 
        $GUID = $GUID_ID_DSK[0] 
        $ID = $GUID_ID_DSK[1] 
        $DSK = $disks[$GUID_ID_DSK[2]]

        #region Precheck
        if (-not($null -eq $GUID -or $null -eq $MainStream -or $null -eq $StartTime -or $null -eq $GUID_ID_DSK -or $null -eq $ID -or $null -eq $DSK)) {
            $GUIDFolder = Get-AbsolutePath -Path ".\Streams\$GUID" 
            try {
                $null = Get-Process -ID $ID -ErrorAction Stop

                if ([string]::IsNullOrEmpty($ID)) { 
                    throw 
                }
                else {

                }
            
            }
            catch {
                Remove-Item $GUIDFolder -Recurse
                continue;
            }
        }
        #endregion Precheck

        #Fetch temporary disks
        if ($MainStream -and $MainStream.Length -gt 0) {
            $rx = [regex]::new("temporary dirs: (.+) and (.+)")
            $Stream = Get-Content $MainStream.FullName -Raw
            $found = $rx.Matches($Stream).Groups
            [HardDrive]$TMPDISK1 = $disks[($found[1].Value | Select-String -Pattern "\w:").Matches[0].Value]
            [HardDrive]$TMPDISK2 = $disks[($found[2].Value | Select-String -Pattern "\w:").Matches[0].Value]
        }
                
        #region Create plotter object
        $curPlotter = [Plotter]::new($ID, $StartTime, $GUID, $GUIDFolder, @($DSK, $TMPDISK1, $TMPDISK2)) 
        $null = $Jobs.Add($curPlotter) 
        #endregion Create plotter object

    }
    #region Fetch existing chia
    $maybeProcess = New-Object -Type 'Collections.Generic.List[System.ComponentModel.Component]';
    $IDsToFilter = New-Object -Type 'Collections.Generic.List[Int]';
    $candidateProcesses = Get-Process | Where-Object { $_.Name -ceq "chia" }
    $null = $Jobs | ForEach-Object { $IDsToFilter.Add($_.PID) }
    foreach ($proc in $candidateProcesses) {
        if ($candidateProcesses.Count -ne 0 -and -not $IDsToFilter.Contains($proc.Id)) {
            $null = $maybeProcess.Add($proc) 
        }
    }
    #merge these two foreach ffs
    foreach ($process in $maybeProcess) {
        $STime = $process.StartTime
        $plotterObj = [Plotter]::new($process.ID, $STime)
        $null = $Jobs.Add($plotterObj)
    }
    #endregion Fetch existing chia


    , $Jobs #powershell what the fuck?
}
