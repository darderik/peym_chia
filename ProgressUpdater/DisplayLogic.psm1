using module .\Classes\UIDocument.psm1;
using module .\Classes\Phase.psm1;
using module .\Classes\Row.psm1;
using module .\Functions\Fetcher.psm1;
using module .\Functions\write-chost.psm1
$mainStrTemplate = "
    /____________________________________________________________________\
    |                                                                    |
    |                                                                    |
    |   Phase         Table      Bucket          Operation               |
    |                                                                    |
    |   {0}           {1}         {2}             {3}                    |
    |   {4}           {5}         {6}             {7}                    |
    |                                                                    |
    |                                                                    |
    |                                                                    |
    |                                                                    |
    |                                                                    |
    |                                                                    |
    |                                                                    |
    |                                                                    |
    |--------------------------------------------------------------------|
    Program Status : {stat}                                              "
#This char[] will be passed by ref
$newStrFormatted = $mainStrTemplate.ToCharArray()
#Create uidocument instance
$Doc = [UIDocument]::new($newStrFormatted)
function DisplayLogic([string]$Status) {

    #
    #grab curphase of all running plotters
    #
    $Streams = Get-ChildItem -Path .\Streams\* -Directory
    [Collections.Generic.List[Row]]$Rows = $Doc.Rows
    $ctr = 0
    foreach ($guidFolder in $Streams) {
        $oputPath = "$($guidFolder.Fullname)\Chia-Plot-$($guidFolder.Name).Log" 
        $GUID_ID_DSK = (Get-Content -Path "$($guidFolder.FullName)\Guid-ID.txt" -ErrorAction SilentlyContinue).Split('|') 
        $ID = $GUID_ID_DSK[1] 
        $curPhase = Fetcher $oputPath
        
        if ($null -eq $curPhase) {
            return
        }
            
        $rowStrings = @([string]$curPhase.value, [string]$curPhase.table, [string]$curPhase.bucket)
        if ($Rows.Count -le $ctr) {
            $Doc.addRow($rowStrings)
        }
        else {
            $Rows[$ctr].writeStrings($rowStrings)
        }
        
        $ctr++
    } 
    if ($Status.Length -gt 0) {
        $Doc.setStatus($Status)
    }
    if (-not $global:DEBUG) {
        Clear-Host
    }
    write-chost (-join $Doc.MainPtr.Value) 
    #write-chost technically still not needed, would be nice to add colors
}