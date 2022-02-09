Param([switch]$f, [switch]$force, [switch]$d, [switch]$isDebug)
$force = $f.IsPresent -or $force.IsPresent
$isDebug = $d.IsPresent -or $isDebug.IsPresent

<#
.SYNOPSIS
  Create Symlink formaat
.DESCRIPTION
  Create Symlink formaat and give formatted data to Set-Symlink function
.EXAMPLE
  # Debug mode. Output `result.txt` file not called Set-Symlink function.
  pwsh symlink.ps1 -d

  # Force mode.
  pwsh symlink.ps1 -f
.OUTPUTS
  Symlink files
#>

# Import SymLink function
$HelperDir = "$HOME/dotfiles/windows/config/powershell-profile/helper";
. "$($HelperDir)/functions.ps1"


# Are you root?
if ($isDebug -eq $false) {
  if (-not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole(`
        [Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Invoke-Expression "sudo $PsCommandPath $(if ($force) {"-force"})"
    exit $?
  }
}


# --------------------------------------------------------------------------------------------------
# Files
# --------------------------------------------------------------------------------------------------
<#
.NOTES
Specification

target(require):
  1. target is the actual directory or file. Relative from `$HOME/dotfiles` or absolute path.
  #! 2. A single string will be converted to target even if it is not specified as target.
  e.g.: @{"windows/config/.bashrc" } → @{ target= "$HOME/dotfiles/windows/config/.bashrc"; path= "$HOME/.bashrc"; name= ".bashrc" }
which one(optional):
  path(option):
    1. The path is relative to $HOME/dotfiles.
    (e.g.: "windows/config")
  fullpath(option):
    1. Path to derive path; if name is not specified, the last path will be used for name.
    (e.g.: "$HOME")

name(option):
  1. the name of the symbolic file
  (e.g.: ".bashrc")
#>
$files = @(
  # vim
  @{ target = "init.vim"; path = ""; name = ".vimrc" }
  @{ target = "init.vim"; path = "AppData/Local/nvim" }
  @{ target = "ginit.vim"; path = "AppData/Local/nvim" }
  # lunarvim
  @{ target = "lvim-config.lua"; fullpath = [IO.Path]::Combine($HOME, "AppData/Local/lvim/config.lua"); }

  # Terminal
  $terminalPath = [IO.Path]::Combine($env:LocalAppData, "Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState/settings.json")
  $terminalPreviewPath = $terminalPath.Replace("Terminal", "TerminalPreview")
  @{ target = "windows\data\windows-terminal.json"; fullpath = $terminalPath; name = "settings.json" } # mode = "copy" }
  @{ target = "windows\data\windows-terminal-preview.json"; fullpath = $terminalPreviewPath; name = "settings.json" } # mode = "copy" }

  # msys2 HomeDir
  $UserName = (Split-Path $HOME -Leaf)
  @{ target = $HOME; fullpath = [IO.Path]::Combine($HOME, "scoop\apps\msys2\current\home\$UserName"); }

  @{ target = "windows\config\keyhac\config.py"; fullpath = [IO.Path]::Combine($env:AppData, "Keyhac\config.py"); }
  @{ target = "windows\config\keyhac\keyhac.ini"; fullpath = [IO.Path]::Combine($env:AppData, "Keyhac\keyhac.ini"); }

  @{ target = "common\data\navi-config.yml"; fullpath = "$(navi info config-path | Write-Output)"; name = "config.yml" } # manual

  "windows/config/.bash_profile"
  "windows/config/.bashrc"
  "linux/.zshrc"
)

$pwshProfilePath = @($(pwsh -NoProfile -Command "`$profile"))[0]
$powerShellProfilePath = @($(powerShell -NoProfile -Command "`$profile"))[0]

# If you have a profile, add it and add it to $files.
if ( (Get-Command pwsh -ea 0) -and (pwsh -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/powershell-profile/profile.ps1"; fullpath = $pwshProfilePath })

  # create symlink from `pwsh's modules` to `powershell's modules`
  $pwshModulePath = [IO.Path]::Combine(($pwshProfilePath | Split-Path), "Modules")
  $powershellModulePath = [IO.Path]::Combine(($powerShellProfilePath | Split-Path), "Modules")
  $files += @(@{ target = $pwshModulePath; fullpath = $powershellModulePath; })
}

if ( (Get-Command powershell -ea 0) -and (powershell -NoProfile -Command "`$profile")) {
  $files += @(@{target = "windows/config/powershell-profile/profile.ps1"; fullpath = $powerShellProfilePath })
}


# --------------------------------------------------------------------------------------------------
# Create Symbolic link
# --------------------------------------------------------------------------------------------------
function create_symlink($files) {
  if ($isDebug) {
    Write-Host "Debug mode is running..." -ForegroundColor Blue
    if (Test-Path result.txt) {
      Write-Host "result.txt already exists. Delete it." -ForegroundColor Yellow
      Remove-Item result.txt -Force
    }
  }
  else {
    Write-Host "Symbolic links mode is running..." -ForegroundColor Green
  }

  foreach ($file in $files) {
    if ($file.GetType() -eq [string]) {
      if (!$file) { continue }

      $file = @{target = $file; path = "" }
    }

    $isDrive = (Split-Path $file.target) -match "^[A-Z]:\\"
    if ($isDrive -eq $false) {
      $file.target = [IO.Path]::Combine("$HOME/dotfiles", $file.target)
      if (!$file.name) { $file.name = Split-Path $file.target -Leaf }
    }


    if ( !$file.path ) { $file.path = "$HOME" }
    else { $file.path = [IO.Path]::Combine($HOME, $file.path) }

    if (!$file.name) { $file.name = Split-Path $file.path -Leaf }

    # Overwrite `path`& `name` property if `fullpath` is specified.
    if ($file.fullpath) {
      $file.name = Split-Path $file.fullpath -Leaf
      $file.path = Split-Path $file.fullpath
      $file.Remove("fullpath")
    }


    if ($isDebug) {
      Write-Output @file "`n" | Out-File result.txt -Append # for debug
      Write-Host @file "`n"
      continue
    }

    # Make symlink
    if (!(Test-Path $file.path)) {
      mkdir $file.path
    }
    if ($Force) { Set-SymLink -Hash $file -Force }
    else { Set-SymLink -Hash $file }
  }
}

create_symlink $files
