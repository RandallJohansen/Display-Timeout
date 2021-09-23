


# Set-ExecutionPolicy -executionPolicy  bypass




<#
Subgroup GUID: 7516b95f-f776-4464-8c53-06167f40cc99  (Display)
    GUID Alias: SUB_VIDEO
    Power Setting GUID: 3c0bc021-c8a8-4e07-a973-6b14cbcb2b7e  (Turn off display after)
      GUID Alias: VIDEOIDLE
      Minimum Possible Setting: 0x00000000
      Maximum Possible Setting: 0xffffffff
      Possible Settings increment: 0x00000001
      Possible Settings units: Seconds
    Current AC Power Setting Index: 0x0000012c
    Current DC Power Setting Index: 0x0000012c
#>


class ReadValue {

        [string]ShowValue() {

                #  -Context 20  shows found plus 20 before and 20 after

                $value = [uint32]( ( ( powercfg /query | Select-String -Pattern "\(Display\)" -Context 20 ) -split "`r`n" | 
                    select -Last 21 |
                    where { $_ -match "Current AC Power Setting Index:" } |
                    select -First 1 ) -split ": " |
                    select -Last 1 )

              #  if( $value -eq "0" ) { $value = "off" }

                return $value
        }
}


function Labels {

    $Button.Text = [string]$Timeout.ShowValue()

    if( $Button.Text -eq "0" ) { $Button.BackColor = "green" }
    else { $Button.BackColor = "red" }

    $Form.Text = "Timeout = " + $Button.Text

}


function ToggleDisplayTimer { 

        <#

        The web is full of command lines written for Cmd.exe. These commands lines 
        work often enough in PowerShell, but when they include certain characters, for example, 
        a semicolon (;), a dollar sign ($), or curly braces, you have to make some changes, 
        probably adding some quotes. This seemed to be the source of many minor headaches.
        
        To help address this scenario, we added a new way to “escape” the parsing of command lines. 
        If you use a magic parameter --%, we stop our normal parsing of your command line and 
        switch to something much simpler. We don’t match quotes. We don’t stop at semicolon. 
        We don’t expand PowerShell variables. We do expand environment variables if you use 
        Cmd.exe syntax (e.g. %TEMP%). Other than that, the arguments up to the end of the line 
        (or pipe, if you are piping) are passed as is.

        & powercfg --% /change monitor-timeout-ac 0

        #>

  # [System.Windows.Forms.MessageBox]::Show("Hello World." , "My Dialog Box")

     
        if( $Button.Text -eq "0" ) { 

                 powercfg /change monitor-timeout-ac 5

        } else {
         
                 powercfg /change monitor-timeout-ac 0              
        }              
}


function MakeButton {

    $Form.Height = 400
    $Form.Width = 500
    $Btn = New-Object System.Windows.Forms.Button
    $Btn.Height = $Form.ClientSize.Height
    $Btn.Width = $Form.ClientSize.Width
    $Btn.ForeColor = "white"
    $Btn.add_Click( { $Button.BackColor = "gray" ; ToggleDisplayTimer ; Labels } )

    $Btn # return object for the caller to work with
}


function go {

    [System.Windows.Forms.Application]::EnableVisualStyles();

    # execute code when form is shown
    #$Form.Add_Shown( { $Form.Activate() ; ProcessNewFiles $Hash } )

    $RetCode = $Form.ShowDialog();    # modal

    $Form.close() ; $Form.Dispose()
}

#####################################################################


$Timeout = New-Object -TypeName ReadValue

# create form at top (global) level so functions have write access
Add-Type -AssemblyName System.Windows.Forms ; $Form = New-Object Windows.Forms.Form

$Button = MakeButton ; $Form.controls.add($Button) ; Labels

go
