# Install components to run Jekyll on local Windows workstation

function Write-Message {
    param (
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Is-MSYS2Installed {
    $msys2Path = "C:\msys64\usr\bin\bash.exe"
    return Test-Path $msys2Path
}

Write-Message "[*] STEP 1: Install Ruby via WinGet" "Cyan"

$wingetOutput = winget install --id=RubyInstallerTeam.Ruby.3.2 --source winget 2>&1
if ($wingetOutput -match "Found an existing package already installed.") {
    Write-Message "[+] - Ruby is already installed and up to date!" "Green"
} elseif ($?) {
    Write-Message "[+] - Ruby installed successfully!" "Green"
} else {
    Write-Message "[-] - Failed to install Ruby." "Red"
    exit 1
}

# Note: Run `winget search ruby` to find the latest version

# Install MSYS2 and development toolchain
Write-Message "[*] STEP 1.1: Install MSYS2 and development toolchain" "Cyan"

# ridk install 1
# if ($?) {
#     Write-Message "[+] - MSYS2 and development toolchain installed successfully!" "Green"
# } else {
#     Write-Message "[-] - Failed to install MSYS2 and development toolchain." "Red"
#     exit 1
# }

# NOTE: This attempts to download an old version which is not there, so we need to download the latest version manually:

if (Is-MSYS2Installed) {
    Write-Message "[+] - MSYS2 is already installed!" "Green"
} else {
    $msys2Installer = "https://repo.msys2.org/distrib/x86_64/msys2-x86_64-20241208.exe"
    $msys2InstallerPath = "$env:TEMP\msys2-x86_64-20241208.exe"

    Invoke-WebRequest -Uri $msys2Installer -OutFile $msys2InstallerPath
    if ($?) {
        Write-Message "[+] - MSYS2 installer downloaded successfully!" "Green"
    } else {
        Write-Message "[-] - Failed to download MSYS2 installer." "Red"
        exit 1
    }

    Start-Process -FilePath $msys2InstallerPath -Wait
    if ($?) {
        Write-Message "[+] - MSYS2 installer executed successfully!" "Green"
    } else {
        Write-Message "[-] - Failed to execute MSYS2 installer." "Red"
        exit 1
    }

    # Install development toolchain
    & "C:\msys64\usr\bin\bash.exe" -c "pacman -S --noconfirm base-devel mingw-w64-x86_64-toolchain"
    if ($?) {
        Write-Message "[+] - MSYS2 and development toolchain installed successfully!" "Green"
    } else {
        Write-Message "[-] - Failed to install MSYS2 and development toolchain." "Red"
        exit 1
    }
}

# Ensure MSYS2 is in the PATH
$env:Path += ";C:\msys64\usr\bin;C:\msys64\mingw64\bin"

Write-Message "[*] STEP 2: Install Jekyll via RubyGems" "Cyan"

# NOTE: You need to restart your terminal after installing Ruby because the binary locations were added to your $PATH

gem install jekyll bundler
if ($?) {
    Write-Message "[+] - Jekyll and Bundler installed successfully!" "Green"
} else {
    Write-Message "[-] - Failed to install Jekyll and Bundler." "Red"
    exit 1
}

Write-Message "[*] STEP 3: Install Dependencies" "Cyan"

bundle install
if ($?) {
    Write-Message "[+] - Dependencies installed successfully!" "Green"
} else {
    Write-Message "[-] - Failed to install dependencies." "Red"
    exit 1
}

Write-Message ""
Write-Message "[+] - Jekyll and Bundler have been installed successfully!" "Green"
Write-Message ""
Write-Message "To start the Jekyll server, run the following command:"
Write-Message ""
Write-Message "  bundle exec jekyll serve"
Write-Message ""
Write-Message "To start the Jekyll server and include your unpublished drafts, run the following command:"
Write-Message ""
Write-Message "  bundle exec jekyll serve --drafts"
Write-Message ""

Write-Message "[+] Done!" "Green"
