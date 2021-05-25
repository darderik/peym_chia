class Row {
    [int32[]]$positions 
    [ref]$mainString
    [string[]]$writtenStrings
    [string]$Identifier
    [string]$GUID
    Row([ref]$_PointedStr, $_positions) {
        $this.Positions = $_positions
        $this.MainString = $_PointedStr
    }
    [void]writeStrings([string[]]$strArray) {
        if ($strArray.Count -gt $this.positions.Count) {
            return
        }
        if ($this.writtenStrings.Count -gt 0) {
            $this.cleanStrings()
        }
        $j = 0
        foreach ($str in $strArray) {

            $curPos = $this.positions[$j]
            for ($i = 0; $i -lt $str.Length; $i++) {
                #if ([System.String]::IsNullOrWhiteSpace(($this.mainString.Value[$curPos + $i]))) {
                $this.mainString.Value[$curPos + $i] = $str[$i]
                #}
            }
            $j++
        }
        $this.writtenStrings = $strArray
    }

    [void]cleanStrings() {
        for ($i = 0; $i -lt $this.positions.Count; $i++) {
            $curPos = $this.positions[$i]
            $curWord = $this.writtenStrings[$i]
            for ($j = 0; $j -lt $curWord.Length; $j++) {
                $this.mainString.Value[$curPos + $j] = " "
            }
        }
        $this.writtenStrings = @()
    }

}