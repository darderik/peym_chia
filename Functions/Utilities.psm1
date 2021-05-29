using module ..\Classes\PlotterClass.psm1
using module ..\Classes\HardDrive.psm1

function NewPlot ($ChiaExe, $ChiaArguments, [HardDrive[]]$DSKS) {
    [OutputType([Plotter])]
    $GUID = New-Guid
    $GUID = $GUID.ToString()
    $GUIDFolder = ".\Streams\$GUID"
    mkdir $GUIDFolder > $null
    $relStreamPath = ".\Streams\$GUID\Chia-Plot-$GUID.Log"
    $curProc = Start-Process $ChiaExe -ArgumentList $ChiaArguments -Passthru -RedirectStandardOutput $relStreamPath
    $ID = $curProc.Id
    $hdd = $DSKS[0].Label
    "$GUID|$ID|$hdd" | Out-File "$GUIDFolder\Guid-ID.txt"

    $curPlotter = [Plotter]::new($curProc.Id, ( Get-Date ), $GUID, (Get-AbsolutePath -Path $GUIDFolder), $DSKS)
    return $curPlotter
}

Function Get-AbsolutePath {
    param([string]$Path)
    [System.IO.Path]::GetFullPath([System.IO.Path]::Combine((Get-Location).ProviderPath, $Path));
}