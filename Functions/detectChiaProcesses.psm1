using module ..\Classes\PlotterClass.psm1
function DetectChiaPlotters {
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
        $DSK = $GUID_ID_DSK[2]

        #goddamn write a function
        if (-not($null -eq $GUID -or $null -eq $MainStream -or $null -eq $StartTime -or $null -eq $GUID_ID_DSK -or $null -eq $GUID -or $null -eq $ID -or $null -eq $DSK)) {
            $GUIDFolder = Get-AbsolutePath -Path ".\Streams\$GUID" 
            try {
                $null = Get-Process -ID $ID -ErrorAction Stop

                if ([string]::IsNullOrEmpty($ID)) { 
                    throw 
                }
                else {
                    $curPlotter = [Plotter]::new($ID, $StartTime, $GUID, $GUIDFolder, $DSK) 
                    $null = $Jobs.Add($curPlotter) 
                }
            
            }
            catch {
                Remove-Item $GUIDFolder -Recurse
            }
        }
    }
    #Are there any running plotters unknown to the script?
    $maybeProcess = New-Object -Type 'Collections.Generic.List[System.ComponentModel.Component]';
    $candidateProcessesIds = New-Object -Type 'Collections.Generic.List[Int]';
    $candidateProcesses = Get-Process | Where-Object { $_.Name -ceq "chia" }
    $null = $candidateProcesses | ForEach-Object { $candidateProcessesIds.Add($_.Id) }
    foreach ($proc in $candidateProcesses) {
        if ($candidateProcesses.Count -ne 0 -and -not $candidateProcessesIds.Contains($proc.Id)) {
            $null = $maybeProcess.Add($proc) 
        }
    }
    #merge these two foreach ffs
    foreach ($process in $maybeProcess) {
        $STime = $process.StartTime
        $plotterObj = [Plotter]::new($process.ID, $STime)
        $null = $Jobs.Add($plotterObj)
    }



    , $Jobs #powershell what the fuck?
}
