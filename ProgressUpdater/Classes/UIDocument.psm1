using module ..\Functions\Write-Bytes.psm1
using module .\Row.psm1
class UIDocument {
    [int[]]$Positions
    [int[]]$FirstRowPositions
    [int]$EachRowAmount
    [int]$BytesToNext
    [int]$CurrentRow
    [int]$StatusIdx
    [string]$Status
    [Collections.Generic.List[Row]]$Rows = [Collections.Generic.List[Row]]::new()
    [ref]$MainPtr
    UIDocument([ref]$_MainDoc) {
        if ($_MainDoc.Value.GetType().Name -ne "Char[]") { return }
        $this.MainPtr = $_MainDoc
        $joinedStr = -join $_MainDoc.Value
        $reX = [regex]::new("{\d}")
        $placeHolders = $reX.Matches($joinedStr) 
 
        $this.positions = $placeHolders | ForEach-Object { $_.Index }
        $this.EachRowAmount = $placeHolders.Count / 2 #we expect a even number
        $this.FirstRowPositions = ($this.Positions | Select-Object -First $this.EachRowAmount)
        $this.BytesToNext = $joinedStr.IndexOf("{$($this.EachRowAmount)}") - $joinedStr.IndexOf("{0}")


        #Take status index (if present)
        $reX = [regex]::new("{[a-z]+}")
        $statusIndex = $reX.Matches($joinedStr)
        if ($statusIndex.Count -gt 0) {
            $this.StatusIdx = $statusIndex[0].Index 
        }

        #clean all placeholders
        $reX = [regex]::new("{\w+}")
        $pHsToRemove = $reX.Matches($joinedStr)
        foreach ($pH in $pHsToRemove) {
            $length = $ph.Length
            $idx = $ph.Index
            Write-Bytes " " $this.MainPtr $idx $length
        } 
    }
    [Row]addRow([string[]]$ToInsert) {
        $rowPositions = $this.FirstRowPositions | ForEach-Object { $_ + ($this.CurrentRow * $this.BytesToNext) }
        $rowInstance = [Row]::new($this.MainPtr, $rowPositions)
        $rowInstance.writeStrings($ToInsert)
        $this.Rows.Add($rowInstance)
        $this.CurrentRow++
        return $rowInstance
    }
    [Row]addRow() {
        $rowPositions = $this.FirstRowPositions | ForEach-Object { $_ + ($this.CurrentRow * $this.BytesToNext) }
        $rowInstance = [Row]::new($this.MainPtr, $rowPositions)
        $this.Rows.Add($rowInstance)
        $this.CurrentRow++
        return $rowInstance
    }

    [void]setStatus([string]$Stat) {
        if ($this.Status.Length -gt 0) {
            #Clean the status
            Write-Bytes "" $this.MainPtr  $this.StatusIdx  $this.Status.Length
        }
        Write-Bytes  $Stat  $this.MainPtr  $this.StatusIdx 
        $this.Status = $Stat
    }
}
