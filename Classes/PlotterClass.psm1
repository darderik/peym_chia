using module .\HardDrive.psm1
class Plotter {
    
    [int32]$PID
    [datetime]$StartTime
    $Disks = [PSCustomObject]@{
        TargetDisk             = $null
        TemporaryDisk          = $null
        SecondaryTemporaryDisk = $null
    };
    [string]$GUID 
    [String]$LogFolder
    [string]$LogFile
    [System.Diagnostics.Process]$Process


    Plotter([int32]$_PID, [datetime]$_StartTime, [string]$_GUID, [string]$_GUIDFolder, [HardDrive[]]$_DSKS) {
        $this.PID = $_PID
        $this.StartTime = $_StartTime
        try {
            $this.Process = Get-Process -ID $_PID -ErrorAction Stop
        }
        catch { return } #No process
        $this.GUID = $_GUID
        $this.LogFolder = $_GUIDFolder
        $this.LogFile = (Get-Item -Path "$($this.LogFolder)\*" | Where-Object { $_.Name.Contains($_guid) })[0].FullName
        $this.Disks.TargetDisk = $_DSKS[0]
        $this.Disks.TemporaryDisk = $_DSKS[1]
        $this.Disks.SecondaryTemporaryDisk = $_DSKS[2]
        $disksObjAmount = 0
        if ($this.Disks.SecondaryTemporaryDisk -eq $this.Disks.TemporaryDisk) {
            $disksObjAmount = 2
        }
        else {
            $disksObjAmount = 3
        }
        for ($i = 0; $i -lt $disksObjAmount; $i++) {
            $curDsk = $_DSKS[$i]
            $curDsk.LinkedPlotters.Add($this.PID, @{
                    Role   = $i 
                    Object = $this 
                })
        }

    }
    Plotter([int32]$_PID, [datetime]$_StartTime) {
        $this.PID = $_PID
        $this.StartTime = $_StartTime
        $this.Process = Get-Process -ID $_PID 

    }
    [void]Dispose() {
        if ($null -ne $this.LogFolder -and "" -ne $this.LogFolder) {
            Remove-Item -Path $this.LogFolder -Recurse
        }
        $this.Disks.TargetDisk.LinkedPlotters.Remove($this.PID) 
        $this.Disks.TemporaryDisk.LinkedPlotters.Remove($this.PID) 
        $this.Disks.SecondaryTemporaryDisk.LinkedPlotters.Remove($this.PID) 
    }
}
