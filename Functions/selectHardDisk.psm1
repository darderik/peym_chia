using module ..\Classes\HardDrive.psm1
function selectHardDisk ([hashtable]$disks, [int]$ctr = 0, [int]$Role) {
    foreach ($dsk in $disks.Keys) {
        $curDisk = $disks[$dsk]
        $condition = $Role -eq 0 ? ($curDisk.getProjectedFreeSpace(1GB, 2) -gt $global:plotSize -and $curDisk.Role -eq 0) : ($curDisk.getProjectedFreeSpace(1GB, 2) -gt $global:tempPlotSize -and $curDisk.Role -eq 1 )
        if ($condition) {
            return $curDisk.Label
        }  
    }
}

