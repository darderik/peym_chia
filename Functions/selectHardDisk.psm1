function selectHardDisk ($disks, $plotSize, [int]$ctr) {
    #Select first hdd with at least $plotSize free gb
    if ($ctr -ge $disks.Count) {
        return ""
    }
    $dsk = $disks[$ctr]
    $dskRelPath = -join ("$dsk", "\")
    $freeSpace = [int64]((Get-Volume -FilePath $dskRelPath).SizeRemaining / (1024 * 1024 * 1024))
    if ($freeSpace -le $plotSize) {
        $increment = $ctr + 1
        return selectHardDisk $disks $plotSize $increment
    }
    else {
        return $dsk
    }
}