function write-chost($message = "") {
    [string]$pipedMessage = @($Input)
    if (!$message) {  
        if ( $pipedMessage ) {
            $message = $pipedMessage
        }
    }
    if ( $message ) {
        # predefined Color Array
        $colors = @("black", "blue", "cyan", "darkblue", "darkcyan", "darkgray", "darkgreen", "darkmagenta", "darkred", "darkyellow", "gray", "green", "magenta", "red", "white", "yellow");
 
        # Get the default Foreground Color
        $defaultFGColor = $host.UI.RawUI.ForegroundColor
 
        # Set CurrentColor to default Foreground Color
        $CurrentColor = $defaultFGColor
 
        # Split Messages
        $message = $message.split("#")
 
        # Iterate through splitted array
        foreach ( $string in $message ) {
            # If a string between #-Tags is equal to any predefined color, and is equal to the defaultcolor: set current color
            if ( $colors -contains $string.tolower() -and $CurrentColor -eq $defaultFGColor ) {
                $CurrentColor = $string          
            }
            else {
                # If string is a output message, than write string with current color (with no line break)
                write-host -nonewline -f $CurrentColor $string
                # Reset current color
                $CurrentColor = $defaultFGColor
            }
            # Write Empty String at the End
        }
        # Single write-host for the final line break
        write-host
    }
}