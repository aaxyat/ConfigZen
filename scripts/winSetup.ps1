# Check if PowerShell 7 is installed using winget
$wingetPS7 = Get-WindowsPackage -Name "PowerShell" -Version "7.*"
if (!$wingetPS7) {
    # PowerShell 7 is not installed, so install it using winget.
    Write-Host "Installing PowerShell 7 using winget..."
    Start-Process -FilePath "winget" -ArgumentList "install -e --id=Microsoft.PowerShell -v 7" -Wait

    # Restart the script with elevated privileges using PowerShell 7.
    Write-Host "Restarting script with elevated privileges using PowerShell 7..."
    $arguments = "& '" + $myinvocation.mycommand.definition + "'"
    Start-Process -FilePath "pwsh" -Verb runAs -ArgumentList $arguments
    Exit
}

# Rest of the script that runs in PowerShell 7

# Install startallback using winget (run this with elevated privileges)
$startallback = Get-WindowsPackage -Name "StartAllBack" -Version "1.1.0"
if (!$startallback) {
    Write-Host "Installing StartAllBack using winget..."
    winget install --id=StartAllBack
}

# Set execution policy to unrestricted (for PowerShell 7)
Write-Host "Setting execution policy to unrestricted for PowerShell 7..."
Set-ExecutionPolicy Unrestricted -Scope CurrentUser -Force

# Install PowerShellGet and PSReadLine with prediction support (for PowerShell 7)
Write-Host "Installing PowerShellGet and PSReadLine for PowerShell 7..."
Install-Module -Name PowerShellGet -Force
Install-Module -Name PSReadLine -AllowPrerelease -Force -Confirm:$false

# Set PSReadLine options for prediction (for PowerShell 7).
Write-Host "Setting PSReadLine options for prediction for PowerShell 7..."
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView

# Install PowerShell 7 specific packages and perform other actions using PowerShell 7.
Write-Host "Installing PowerShell 7 specific packages and performing other actions..."
Start-Process pwsh -ArgumentList "-NoExit -Command {
    # Install PowerShell 7 specific modules and perform other actions
    Install-Module -Name PSReadLine -AllowPrerelease -Force -Confirm:$false
    # ... Add other PowerShell 7 specific commands here ...
    choco install powershell-core -y
    # ... Add other PowerShell 7 specific commands here ...
}" -Wait

# Continue with the rest of the script in PowerShell 7.

# install following packages through chocolatey : "python", "autohotkey", "vscode", "windirstat", "winfsp", "nssm", "brave", "epicgameslauncher", "termius", "telegram", "steam", "notepadplusplus.install", "gsudo", "git", "starship", "7zip", "thunderbird", "discord", "vlc", "mpv", "teracopy", "qbittorrent", "dotnet-runtime", "rclone", "yt-dlp", "k-litecodecpackfull", "revo-uninstaller", "adb", "firacode", "autohotkey", "nodejs.install", "curl", "stremio"
$packages = "python", "autohotkey", "vscode", "windirstat", "winfsp", "nssm", "brave", "epicgameslauncher", "termius", "telegram", "steam", "notepadplusplus.install", "gsudo", "git", "starship", "7zip", "thunderbird", "discord", "vlc", "mpv", "teracopy", "qbittorrent", "dotnet-runtime", "rclone", "yt-dlp", "k-litecodecpackfull", "revo-uninstaller", "adb", "firacode", "autohotkey", "nodejs.install", "curl", "stremio"
foreach ($package in $packages) {
    Write-Host "Installing package '$package' using Chocolatey..."
    choco install $package -y
}

# get https://gist.githubusercontent.com/aaxyat/d8b1405d9b83b2973ffdec665ebec55b/raw/a598ed15dde692c3596269d0cab845d7a5e86f28/Microsoft.PowerShell_profile.ps1 and install this as powershell 7 profile
Write-Host "Setting up PowerShell 7 profile..."
Invoke-WebRequest -Uri https://gist.githubusercontent.com/aaxyat/d8b1405d9b83b2973ffdec665ebec55b/raw/a598ed15dde692c3596269d0cab845d7a5e86f28/Microsoft.PowerShell_profile.ps1 -OutFile $PROFILE

# install Windows Terminal settings file which is located at https://gist.githubusercontent.com/aaxyat/2d988708e412dbf7f553bec580ea81a9/raw/03462babd371879db0cd1cfddf8cb07f838b0982/settings.json
Write-Host "Setting up Windows Terminal settings..."
Invoke-WebRequest -Uri https://gist.githubusercontent.com/aaxyat/2d988708e412dbf7f553bec580ea81a9/raw/03462babd371879db0cd1cfddf8cb07f838b0982/settings.json -OutFile $env:LOCALAPPDATA\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json

# setup starship with config file located at https://gist.githubusercontent.com/aaxyat/0918cf52a83461290547fe4beedf28df/raw/7d94a67b90b51170760568290bdd655ba48f9ff8/starship.toml
$starshipConfigPath = "$env:USERPROFILE\.config"
$starshipTomlPath = Join-Path $starshipConfigPath "starship.toml"

# Create the .config directory if it doesn't exist
if (-Not (Test-Path $starshipConfigPath)) {
    Write-Host "Creating .config directory..."
    New-Item -ItemType Directory -Path $starshipConfigPath -Force
}

# Download and place the starship.toml file in the .config directory
Write-Host "Setting up Starship prompt..."
Invoke-WebRequest -Uri "https://gist.githubusercontent.com/aaxyat/0918cf52a83461290547fe4beedf28df/raw/7d94a67b90b51170760568290bdd655ba48f9ff8/starship.toml" -OutFile $starshipTomlPath

#compile the AutohotKey script located at https://gist.githubusercontent.com/aaxyat/8458a22d1fc6b296bb9ee8c8eea5be51/raw/6429c7c8fb5738ac79d18f8853852fd63f7208d0/shortcuts.ahk  to exe and make the exe file launch at startup. The autohotkey package is installed via chocolaty so fix your path according to the instruction
$ahkScriptPath = "$env:USERPROFILE\Documents\shortcuts.ahk"
$exeOutputPath = "$env:USERPROFILE\Documents\shortcuts.exe"

Write-Host "Compiling AutoHotkey script..."
& "C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe" /in $ahkScriptPath /out $exeOutputPath

$shortcutPath = Join-Path ([System.Environment]::GetFolderPath("Startup")) "shortcuts.lnk"
$WScriptShell = New-Object -ComObject WScript.Shell
$Shortcut = $WScriptShell.CreateShortcut($shortcutPath)
$Shortcut.TargetPath = $exeOutputPath
$Shortcut.Save()

Write-Host "Script execution completed successfully!"