using module ..\Classes\HardDrive.psm1
function selectTargetHardDisk ([hashtable]$disks, [int]$ctr = 0) {
    foreach ($dsk in $disks.Keys) {
        $curDisk = $disks[$dsk]
        $condition = $global:filterTempDisks ? ($curDisk.getProjectedFreeSpace(1GB, 2) -gt $global:plotSize -and $curDisk.Role -eq 0) : ($curDisk.getProjectedFreeSpace(1GB, 2) -gt $global:plotSize)
        if ($condition) {
            return $curDisk.Label
        }  
    }
}

