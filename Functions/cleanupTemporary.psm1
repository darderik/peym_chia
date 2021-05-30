function cleanupTemporary([string]$Folder) {

    $plotKeys = (Get-ChildItem $Folder | Where-Object { $_.Name | Select-String -Pattern "\w{64}" }) 
    | ForEach-Object { ($_.Name | Select-String -Pattern "\w{64}").Matches[0].Value } | Sort-Object -Unique

    foreach ($key in $plotKeys) {
        $matchingFiles = Get-ChildItem $Folder | Where-Object { $_.Name.Contains($key) }
        [bool]$isBeingUsed = $false
        foreach ($file in $matchingFiles) {
            try {
                $dummyStream = [System.IO.StreamWriter]::new( $file.FullName )
            }
            catch {
                $isBeingUsed = $true
                break           
            }
            finally {
                if ($dummyStream -ne $null) {
                    $dummyStream.close() 
                }
            }
        }
        if (-not $isBeingUsed) {
            foreach ($file in $matchingFiles) {
                Remove-Item -Path $file.FullName -ErrorAction Stop -Force
            }
        }
    }
}
