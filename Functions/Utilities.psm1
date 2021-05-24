using module ..\Classes\PlotterClass.psm1

function Initialize ($TempDiskFree, $temporaryFolder) {
    #Clean curFolder of all .LOG files
    Remove-Item ".\Streams\*.log" -ErrorAction SilentlyContinue
    # Remove-Item -Recurse -Path "$temporaryFolder\*" -ErrorAction SilentlyContinue
    # Still not ready to delete left tmp plots, too risky
}

function NewPlot ($ChiaExe, $ChiaArguments, $hdd) {
    [OutputType([Plotter])]
    $GUID = New-Guid
    $GUID = $GUID.ToString()
    $GUIDFolder = ".\Streams\$GUID"
    mkdir $GUIDFolder > $null
    $relStreamPath = ".\Streams\$GUID\Chia-Plot-$GUID.Log"
    $curProc = Start-Process $ChiaExe -ArgumentList $ChiaArguments -Passthru -RedirectStandardOutput $relStreamPath
    $ID = $curProc.Id
    "$GUID|$ID|$hdd" | Out-File "$GUIDFolder\Guid-ID.txt"

    $curPlotter = [Plotter]::new($curProc.Id, ( Get-Date ), $GUID, (Get-AbsolutePath -Path $GUIDFolder), $hdd)
    return $curPlotter
}

Function Get-AbsolutePath {
    param([string]$Path)
    [System.IO.Path]::GetFullPath([System.IO.Path]::Combine((Get-Location).ProviderPath, $Path));
}