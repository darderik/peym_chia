class Plotter {
    [int32]$PID
    [datetime]$StartTime
    [string]$BoundDisk
    [string]$GUID 
    [String]$LogFolder
    [string]$LogFile
    [System.Diagnostics.Process]$Process

    Plotter([int32]$_PID, [datetime]$_StartTime, $_GUID, $_GUIDFolder, $_DSK) {
        $this.PID = $_PID
        $this.StartTime = $_StartTime
        $this.BoundDisk = $_DSK
        $this.Process = Get-Process -ID $_PID 
        $this.GUID = $_GUID
        $this.LogFolder = $_GUIDFolder
        $this.LogFile = (Get-Item -Path "$($this.LogFolder)\*" | Where-Object { $_.Name.Contains($_guid) })[0].FullName

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
    }
}