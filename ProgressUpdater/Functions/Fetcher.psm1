using module ..\Classes\Phase.psm1
function Fetcher([string]$logFile) {
    if (-not (Test-Path $logFile)) { return }
    $fileRaw = Get-Content $logFile
    if ([string]::IsNullOrEmpty($fileRaw)) {
        return
    }

    $cIR = ([regex]$RX).Options -bor [System.Text.RegularExpressions.RegexOptions]::IgnoreCase
    #regex
    $_Matches = [regex]::new("(phase \d/\d)", $cIR).Matches($fileRaw)
    if ($_Matches.Count -gt 0) {
        $lastMatch = $_Matches[$_Matches.Count - 1].Value
        $phaseInt = [int]([regex]::new("phase (\d)/\d", $cIR).Match($lastMatch).Groups[1].Value)
    }

    $phaseObj = [Phase]::new()
    $phaseObj.value = $phaseInt
    $phaseObj.file = $logFile
    try {
        switch ($phaseInt) {
            1 { 
                #Phase 1
                #TABLE
                $curTable = [regex]::new("computing table (\d)", $cIR).Matches($fileRaw)
                $curTable = $curTable[$curTable.Count - 1].Groups[1].Value
            
                #Bucket
                $curBucket = [regex]::new("bucket (\d+)", $cIR).Matches($fileRaw)
                $curBucket = [int16]$curBucket[$curBucket.Count - 1].Groups[1].Value

                #assign
                $phaseObj.bucket = $curBucket
                $phaseObj.table = $curTable
            
            }
            2 {
                #Backpropagating table
                $curTableBP = [regex]::new("backpropagating on table (\d)", $cIR).Matches($fileRaw)
                $curTableBP = $curTableBP[$curTable.Count - 1].Groups[1].Value
                $phaseObj.bucket = $curBucket
                $phaseObj.table = $curTableBP
            }
            3 { 
                $curTableCP = [regex]::new("compressing tables (\d) and (\d)", $cIR).Matches($fileRaw)
                $switchCount = $curTableCP.Count
                $firstTable = $curTableCP[$curTableCP.Count - 1].Groups[1].Value
                $secondTable = $curTableCP[$curTableCP.Count - 1].Groups[2].Value


                #1 or 2?
                $firstComputationPass = [regex]::new("First computation pass", $cIR).Matches($fileRaw)
                if ($switchCount -ne $firstComputationPass.Count) {
                    $mainTable = $firstTable
                }
                else {
                    $mainTable = $secondTable

                }
                #Bucket
                $curBucket = [regex]::new("bucket (\d+)", $cIR).Matches($fileRaw)
                $curBucket = $curBucket[$curBucket.Count - 1].Groups[1].Value

                $phaseObj.bucket = $curBucket
                $phaseObj.table = $mainTable
            }
            4 { 
                #Bucket
                $curBucket = [regex]::new("bucket (\d+)", $cIR).Matches($fileRaw)
                $curBucket = $curBucket[$curBucket.Count - 1].Groups[1].Value

                $phaseObj.bucket = $curBucket
            }
            Default {}
        }
    }
    catch {
        return $null
    }
    return $phaseObj 
}