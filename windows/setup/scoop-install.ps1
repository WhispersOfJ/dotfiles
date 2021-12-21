<#
.SYNOPSIS
  Batch to install apps on scoop

.DESCRIPTION
  Batch to install apps on scoop
.EXAMPLE
  windows\setup\scoop-install.ps1
.EXAMPLE
  # Install Languages too.
  windows\setup\scoop-install.ps1 -Languages
#>
Param (
  [switch]$Languages
)

# --------------------------------------------------------------------------------------------------
# Aliases(to like pnpm commands) reference: JP(https://qiita.com/nimzo6689/items/53c63439f56ccd2d38c1)
# --------------------------------------------------------------------------------------------------
# install
scoop alias add i 'scoop install $args[0]' 'Install Scoop apps.'
scoop alias add add 'scoop install $args[0]' 'Install Scoop apps.'

# uninstall
scoop alias add uni 'scoop uninstall $args[0]' 'Remove Scoop apps.'
scoop alias add rm 'scoop uninstall $args[0]' 'Remove Scoop apps.'
scoop alias add remove 'scoop uninstall $args[0]' 'Remove Scoop apps.'

# upgrade
scoop alias add upgrade 'scoop update *' 'Update all apps.'
scoop alias add up 'scoop upgrade' 'Update all apps.'

# Delete cache
scoop alias add prune 'scoop cleanup * --cache' 'Clean Scoop apps by removing old versions and caches.'

# Update all & show status
scoop alias add outdated 'scoop update; scoop status' 'Show all outdated Scoop apps.'

# reinstall
scoop alias add ri 'scoop uninstall $args[0]; scoop install $args[0]' 'Uninstall and then install app'
scoop alias add reinstall 'scoop uninstall $args[0]; scoop install $args[0]' 'Uninstall and then install app'

scoop alias add ls 'scoop list' 'Show installed apps list'

scoop alias add s 'scoop search $args[0]' 'Search Scoop apps'

# reset(To nvm like)
scoop alias add rs 'scoop reset $args[0]' 'Reset an app to resolve conflicts'
scoop alias add use 'scoop reset $args[0]' 'Reset an app to resolve conflicts'


Write-Host "Next, install app by scoop..." -ForegroundColor Green
# --------------------------------------------------------------------------------------------------
# Add fetch destination
# --------------------------------------------------------------------------------------------------
scoop bucket add extras
scoop bucket add versions
scoop bucket add nerd-fonts # For Terminal(oh-my-posh design) font(https://github.com/matthewjberger/scoop-nerd-fonts)
scoop bucket add games


# --------------------------------------------------------------------------------------------------
# Unix like for Windows
# --------------------------------------------------------------------------------------------------
scoop install msys2 # windows in Unix shell: info JP(https://qiita.com/Ted-HM/items/4f2feb9fdacb6c72083c)
msys2 -mintty

scoop install make
scoop install cmake
scoop install psutils


# --------------------------------------------------------------------------------------------------
# Shell design
# --------------------------------------------------------------------------------------------------
scoop install https://github.com/JanDeDobbeleer/oh-my-posh/releases/latest/download/oh-my-posh.json
scoop install CodeNewRoman-NF-Mono


# --------------------------------------------------------------------------------------------------
# Code Conventions
# --------------------------------------------------------------------------------------------------
# Formatter
scoop install shfmt # Makefile formatter

# Linter
scoop install hadolint # Docker linter


# --------------------------------------------------------------------------------------------------
# Convenience
# --------------------------------------------------------------------------------------------------
# Helper
scoop install Capture2Text # Can read text from video.
scoop install autohotkey # Keyboard config (For windows\config\init.ahk file)
scoop install resource-hacker # exe icon edit

scoop install scoop-search # Makes scoop search 50 times faster.(https://github.com/shilangyu/scoop-search)
scoop install dockercompletion

# Instead of command
scoop install bat   # instead of `cat` Syntax highlighting and Git integration(https://github.com/sharkdp/bat)
scoop install fd    # instead of `find` commnad with color
scoop install lsd   # instead of `ls` commnad with color
scoop install procs # instead of `ps` commnad with color
scoop install ripgrep # instead of `grep` commnad with color

# Terminal helper
scoop install concfg # Import and export Windows console settings (https://github.com/lukesampson/concfg)
scoop install fzf # A command-line fuzzy finder written in go.(https://github.com/junegunn/fzf)
scoop install pshazz # Git and Mercurial tab completion, etc... (https://github.com/lukesampson/pshazz)


# --------------------------------------------------------------------------------------------------
# File converter
# --------------------------------------------------------------------------------------------------
scoop install imagemagick # Image converter
scoop install pandoc # Markdown to PDF


# --------------------------------------------------------------------------------------------------
# Editor
# --------------------------------------------------------------------------------------------------
scoop install vim
scoop install neovim


# --------------------------------------------------------------------------------------------------
# Performance
# --------------------------------------------------------------------------------------------------
scoop install hyperfine # A benchmarking tool written in rust.(https://github.com/sharkdp/hyperfine)


# --------------------------------------------------------------------------------------------------
# Languages(option)
# --------------------------------------------------------------------------------------------------
if ($Languages) {
  scoop install deno
  scoop install python27 # latest python version (e.g. python2.7) for other software.
}
