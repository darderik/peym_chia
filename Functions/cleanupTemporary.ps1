function cleanupTemporary([string]$Folder) {

    $plotKeys = (Get-ChildItem $Folder | Where-Object { $_.Name | Select-String -Pattern "\w{64}" }) 
    | ForEach-Object { ($_.Name | Select-String -Pattern "\w{64}").Matches[0].Value } | Sort-Object -Unique

    foreach ($key in $plotKeys) {
        $matchingFiles = Get-ChildItem $Folder | Where-Object { $_.Name.Contains($key) }
        [bool]$isBeingUsed = $false
        foreach ($file in $matchingFiles) {
            try {
                $dummyStream = $file.OpenWrite()
            }
            catch {

                $isBeingUsed = $true
                break           
            }
        }
        if ($null -ne $dummyStream) {
            $dummyStream.Dispose()
            $dummyStream.Close()
        }
        if (-not $isBeingUsed) {
            foreach ($file in $matchingFiles) {
                Remove-Item -Path $file.FullName
            }

        }
    }
}