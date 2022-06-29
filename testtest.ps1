#elevated admin powershell access

param([switch]$Elevated)
function Test-Admin {
    $currentUser = New-Object Security.Principal.WindowsPrincipal $([Security.Principal.WindowsIdentity]::GetCurrent())
    $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
}
if ((Test-Admin) -eq $false)  {
    if ($elevated) {
        # tried to elevate, did not work, aborting
    } else {
        Start-Process powershell.exe -Verb RunAs -ArgumentList ('-noprofile -noexit -file "{0}" -elevated' -f ($myinvocation.MyCommand.Definition))
    }
    exit
}

#enables and resets WinRM

Enable-PSRemoting -SkipNetworkProfileCheck -Force

#Prompts to enter computer name

$compName = Read-Host "Enter Computer Name Here"

#starts a remote session and prompts for credentials

$newSession = New-PSSession -ComputerName $compName -Credential (Get-Credential)

#file directory of two paths

$itemPath1 = "C:\file\path\all\items\*" #remove astrisk to just copy folder
$itemPath2 = "C:\remote\destination\"

#copies items to destinations

Copy-Item -Path $itemPath1 -Destination $itemPath2 -ToSession $newSession

#verifies if transfer went through

Invoke-Command -ScriptBlock {Get-ChildItem -Path $itemPath1 } -Session $newSession

#terminates remote session
Remove-PSSession -Session $newSession

