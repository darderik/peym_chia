using module .\HardDrive.psm1
class HardDriveNode {
    [HardDrive]$Value
    [HardDriveNode]$Next
    #[HardDriveNode]$Prev
    HardDriveNode([HardDrive[]]$HdArray, [int]$mode = 0) {
        [HardDriveNode]$Head = $null
        [HardDriveNode]$prev = $null

        for ($i = 0; $i -le $HdArray.Count; $i++) {

            if ($i -eq 0) {
                $Head = $this
                $prev = $this
                $this.Value = $HdArray[$i]
            }
            elseif ($i -lt $HdArray.count) {
                $curNode = [HardDriveNode]::new()
                $curNode.Value = $HdArray[$i]
                $prev.Next = $curNode
                $prev = $curNode
            }
            elseif ($mode -eq 8) {
                #circular list
                $prev.Next = $Head
            }
            else {
                $prev.Next = $null
            }
        }
    }
    HardDriveNode() {}
}
