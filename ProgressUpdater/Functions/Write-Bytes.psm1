
function Write-Bytes([string]$Str, [ref]$MainString, [int]$Offset, [int]$Size = 0) {
    
    if ([String]::IsNullOrWhiteSpace($Str) -and $Size -ne 0) {
        #clean
        for ($i = 0; $i -lt $Size; $i++) {
            $MainString.Value[$Offset + $i] = " "
        }
    }
    else {
        for ($i = 0; $i -lt $Str.Length; $i++) {
            $MainString.Value[$Offset + $i] = $Str[$i]
        }
    }
}