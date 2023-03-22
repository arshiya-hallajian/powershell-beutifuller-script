
#install winget getted from internet :|
Function Install-WinGet {
    #Install the latest package from GitHub
    [cmdletbinding(SupportsShouldProcess)]
    [alias("iwg")]
    [OutputType("None")]
    [OutputType("Microsoft.Windows.Appx.PackageManager.Commands.AppxPackage")]
    Param(
        [Parameter(HelpMessage = "Display the AppxPackage after installation.")]
        [switch]$Passthru
    )

    Write-Verbose "[$((Get-Date).TimeofDay)] Starting $($myinvocation.mycommand)"

    if ($PSVersionTable.PSVersion.Major -eq 7) {
        Write-Warning "This command does not work in PowerShell 7. You must install in Windows PowerShell."
        return
    }

    #test for requirement
    $Requirement = Get-AppPackage "Microsoft.DesktopAppInstaller"
    if (-Not $requirement) {
        Write-Verbose "Installing Desktop App Installer requirement"
        Try {
            Add-AppxPackage -Path "https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx" -erroraction Stop
        }
        Catch {
            Throw $_
        }
    }

    $uri = "https://api.github.com/repos/microsoft/winget-cli/releases"

    Try {
        Write-Verbose "[$((Get-Date).TimeofDay)] Getting information from $uri"
        $get = Invoke-RestMethod -uri $uri -Method Get -ErrorAction stop

        Write-Verbose "[$((Get-Date).TimeofDay)] getting latest release"
        #$data = $get | Select-Object -first 1
        $data = $get[0].assets | Where-Object name -Match 'msixbundle'

        $appx = $data.browser_download_url
        #$data.assets[0].browser_download_url
        Write-Verbose "[$((Get-Date).TimeofDay)] $appx"
        If ($pscmdlet.ShouldProcess($appx, "Downloading asset")) {
            $file = Join-Path -path $env:temp -ChildPath $data.name

            Write-Verbose "[$((Get-Date).TimeofDay)] Saving to $file"
            Invoke-WebRequest -Uri $appx -UseBasicParsing -DisableKeepAlive -OutFile $file

            Write-Verbose "[$((Get-Date).TimeofDay)] Adding Appx Package"
            Add-AppxPackage -Path $file -ErrorAction Stop

            if ($passthru) {
                Get-AppxPackage microsoft.desktopAppInstaller
            }
        }
    } #Try
    Catch {
        Write-Verbose "[$((Get-Date).TimeofDay)] There was an error."
        Throw $_
    }
    Write-Verbose "[$((Get-Date).TimeofDay)] Ending $($myinvocation.mycommand)"
}

function config {

New-Item -Path $home/.zigma -Type Directory -Force
New-Item -Path $home/.zigma/star.toml -Type File -Force


Set-Content -Encoding UTF8 -path $home/.zigma/star.toml -Value '
# ~/.config/starship.toml

# Inserts a blank line between shell prompts
add_newline = true

# Change the default prompt format
format = """[╭╴](238)$env_var$username $os$all\
[╰─](238)$time$character \
"""

# Change the default prompt characters
[character]
success_symbol = "[](238)"
error_symbol = "[](238)"

# Shows an icon that should be included by zshrc script based on the distribution or os
[env_var.STARSHIP_DISTRO]
format = ''[$env_value](bold white)''  # removed space between distro and rest for pwsh
variable = "STARSHIP_DISTRO"
disabled = false


#show time
[time]
disabled = false
format = ''[$time](yellow) ''
time_format = ''%R''
utc_time_offset = ''local''


# Shows the username
[username]
style_user = "red bold"
style_root = "black bold"
format = "[@$user]($style)"
disabled = false  # disable in powershell
show_always = true

[directory]
truncation_length = 3
truncation_symbol = "…/"
home_symbol = " ~"
read_only_style = "197"
read_only = "  "
format = "at [$path]($style)[$read_only]($read_only_style) "

[git_branch]
symbol = " "
format = "on [$symbol$branch]($style) "
truncation_length = 15
truncation_symbol = "…/"
style = "bold green"

[git_status]
format = ''[\($all_status$ahead_behind\)]($style) ''
style = "bold green"
conflicted = "🏳"
up_to_date = " "
untracked = " "
ahead = "⇡${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
behind = "⇣${count}"
stashed = " "
modified = " "
staged = ''[++\($count\)](green)''
renamed = "襁 "
deleted = " "

[docker_context]
format = "via [ $context](bold blue) "

[python]
symbol = " "
python_binary = "python3"

[nodejs]
format = "via [  $version](bold green) "
disabled = true
detect_extentions = [''js'', ''mjs'', ''cjs'', ''ts'', ''mts'', ''cts'']
detect_files = [''package.json'', ''.node-version'']
detect_folders = [''node_modules'']

[os]
format = "[$symbol ](bold blue) "
disabled = false

[os.symbols]
Windows = ""

[deno]
format = "via [🦕 $version](green bold) "

'
}

function Powershell{

$test = test-path $profile.CurrentUserAllHosts


if($test){
    $check = Read-Host -Prompt "you have one ps profile can i remove it?[y or n]"
    if("y" -eq $check){
        Remove-Item -Force $profile.CurrentUserAllHosts
    }else{
        exit
    }
}

Set-ExecutionPolicy RemoteSigned


New-Item -Path $profile.CurrentUserAllHosts -Type File -Force


Set-Content -Encoding UTF8 $profile.CurrentUserAllHosts -Value 'New-Alias g goto

function goto {
    param (
        $location
    )

    Switch ($location) {
        "shine" {
            Set-Location -Path "D:\Work\Intellij projects\tg team project\Shine"
        }
        "g2g" {
            Set-Location -Path "$HOME/projects/boilerplates"
        }
        default {
            echo "Invalid location"
        }
    }
}


$ENV:STARSHIP_CONFIG = "$HOME\.zigma\star.toml"
$ENV:STARSHIP_DISTRO = "zigma"
Invoke-Expression (&starship init powershell)'



}

function fontInstall {


$fontask = Read-Host -Prompt "do you want to install font first?[y or n] "

if("y" -eq $fontask){
$sourceDIr = "./fonts"
$source = "./fonts/*"
$Destination = (New-Object -ComObject Shell.Application).Namespace(0x14)
$TempFolder  = "$home/.zigma/Temp/Fonts"


New-Item $TempFolder -Type Directory -Force | Out-Null

Get-ChildItem -Path $Source -Include '*.ttf','*.ttc','*.otf' -Recurse | ForEach {
    If (-not(Test-Path "C:\Windows\Fonts\$($_.Name)")) {

        $Font = "$TempFolder\$($_.Name)"


        Copy-Item $($_.FullName) -Destination $TempFolder
        
        $Destination.CopyHere($Font,0x10)

        Remove-Item $Font -Force
    }
}
Remove-Item -Force $TempFolder
}else{
    return 
}

}

function cmd {

Install-WinGet

winget install --id=chrisant996.Clink  -e

$cmddir = "$home/AppData/Local/clink/starship.lua"

New-Item cmddir -Type File -Force 

Set-Content -Encoding UTF8 -Path $cmddir -Value "
load(io.popen('starship init cmd'):read(""*a""))()
os.setenv('STARSHIP_CONFIG', 'C:\\Users\\$env:username\\.zigma\\star.toml')
os.setenv('STARSHIP_DISTRO', 'zigma')

"

}





clear

echo "welcome to my script😎👌"
$ask = Read-Host -Prompt "are you ready to install? [y or n]"


if("y" -eq $ask){

if (-not (Get-Command choco.exe -ErrorAction SilentlyContinue)) {
    echo "Installing chocolatey"
    Set-ExecutionPolicy Bypass -Scope Process -Force; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}


$teststar = Test-Path $home/../../ProgramData/chocolatey/lib/starship
if(-not ($teststar)){
    choco install -y starship
}


clear


fontInstall


clear

echo "=========Choose Your Shell You Want To Design========="
echo "1: Command-lind"
echo "2: Powershell"
echo "3: Install both"
echo "q: Exit"
$ask = Read-Host -Prompt "Make Your Choice By Number: "
switch($ask){
    '1'{
        #echo "koskesh goftam not available"
        cmd
        config
        echo "cmd design installed"
    }
    '2' {
        Powershell
        config
        echo "PowerShell Design Installed"
    }
    '3'{
        powershell
        cmd
        config
        echo "Both Design Installed"
    }
    'q'{
        exit
    }
}

}else{
    echo "****ok bye****"
}




