#    OnlyTgt = 0
#    OnlyTemp = 1
#    Both = 2    

class HardDrive {
    [string]$Label
    [int]$Role 
    [hashtable]$LinkedPlotters = @{}
    [System.Object]$HDDObject
    HardDrive([string]$Path, [int]$_role) {
        $lab = ( $Path | Select-String -Pattern "\w:" ).Matches[0].Value
        $this.Label = $lab
        if ($_role -in 0, 1, 2) {
            $this.Role = $_role
        }
        $absPath = -join ("$($this.Label)", ":")
        $this.HDDObject = Get-Volume -DriveLetter $this.Label[0]
        
    }
    HardDrive([string]$Path) {
        $lab = ( $Path | Select-String -Pattern "\w:" ).Matches[0].Value
        $this.Label = $lab
        $this.Role = 0
        $this.HDDObject = Get-Volume -DriveLetter $this.Label[0]

    }
    [int]getFreeSpace($mUnit) {
        return ($this.HDDObject.SizeRemaining) / $mUnit
    }
    [int]getProjectedFreeSpace($mUnit, [int]$mode) {
        if ($mode -notin 0, 1, 2) {
            throw "Unrecognized mode for getProjectedFreeSpace method" 
        }
        [int[]]$ctrArr = @(0, 0, 0)
        foreach ($item in $this.LinkedPlotters.Keys) {
            $curPlotterRole = $this.LinkedPlotters[$item].Role
            $ctrArr[$curPlotterRole]++
        }
        [int]$toReturn = 0;
        [int]$toSub = 0
        $_plotSize = $global:PlotSize / 1GB * $mUnit
        $_tempPlotSize = $global:tempPlotSize / 1GB * $mUnit
        switch ($mode) {
            0 { 
                $toSub = $ctrArr[0] * $_plotSize
            }
            1 {
                $toSub = $ctrArr[1] * $_tempPlotSize + $ctrArr[2] * $_plotSize
            }
            2 {
                $toSub = $ctrArr[0] * $_plotSize + $ctrArr[1] * $_tempPlotSize + $ctrArr[2] * $_plotSize
            }
            Default {}
        }
        if ($this.HDDObject.SizeRemaining / $mUnit -lt $this.HDDObject.Size / $mUnit - $toSub) {
            $toReturn = $this.HDDObject.SizeRemaining / $mUnit
        }
        else {
            $toReturn = $this.HDDObject.Size / $mUnit - $toSub
        }
        return $toReturn
    }
}