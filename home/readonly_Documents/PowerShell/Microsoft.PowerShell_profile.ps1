# Cache generated shell code; Starship still reads prompt settings on each prompt.
# A new executable path, timestamp, or size automatically creates a fresh cache.
$starshipCommand = Get-Command starship -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($starshipCommand) {
    $starshipInit = $null
    try {
        $starshipFile = Get-Item -LiteralPath $starshipCommand.Source
        if ($starshipFile.LinkType -eq 'SymbolicLink') {
            $starshipFile = $starshipFile.ResolveLinkTarget($true)
        }
        $starshipStamp = "$($starshipFile.FullName)|$($starshipFile.LastWriteTimeUtc.Ticks)|$($starshipFile.Length)"
        $starshipHasher = [System.Security.Cryptography.SHA256]::Create()
        try {
            $starshipKey = [Convert]::ToHexString($starshipHasher.ComputeHash([Text.Encoding]::UTF8.GetBytes($starshipStamp)))
        } finally {
            $starshipHasher.Dispose()
        }
        $starshipCacheDir = Join-Path $env:LOCALAPPDATA 'PowerShell/Cache/starship-init'
        $starshipCacheFile = Join-Path $starshipCacheDir "$starshipKey.ps1"
        if ([IO.File]::Exists($starshipCacheFile)) {
            $starshipInit = [IO.File]::ReadAllText($starshipCacheFile)
        } else {
            $starshipInit = & $starshipFile.FullName init powershell --print-full-init | Out-String
            if ($LASTEXITCODE -ne 0) { throw 'Starship initialization failed.' }
            $null = [IO.Directory]::CreateDirectory($starshipCacheDir)
            $starshipTempFile = "$starshipCacheFile.$([Guid]::NewGuid().ToString('N')).tmp"
            try {
                [IO.File]::WriteAllText($starshipTempFile, $starshipInit)
                [IO.File]::Move($starshipTempFile, $starshipCacheFile, $true)
            } finally {
                if ([IO.File]::Exists($starshipTempFile)) { [IO.File]::Delete($starshipTempFile) }
            }
        }
    } catch {
        # Keep the prompt working if the cache directory is unavailable.
        if (-not $starshipInit) {
            $starshipInit = & $starshipCommand.Source init powershell --print-full-init | Out-String
        }
    }
    if ($starshipInit) { Invoke-Expression $starshipInit }
}

function y {
    $tmp = [IO.Path]::Combine([IO.Path]::GetTempPath(), [IO.Path]::GetRandomFileName())
    try {
        & yazi @args "--cwd-file=$tmp"
        if ([IO.File]::Exists($tmp)) {
            $cwd = [IO.File]::ReadAllText($tmp).TrimEnd([char[]]"`r`n")
            if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path) {
                Set-Location -LiteralPath $cwd
            }
        }
    } finally {
        if ([IO.File]::Exists($tmp)) { [IO.File]::Delete($tmp) }
    }
}

function restart {
    Invoke-Command { & "pwsh.exe" } -NoNewScope # PowerShell 7
}


# Shortcuts shared with dot_zshrc. Functions allow fixed options and extra arguments.
function fdfind {
    fd -H @args
}

function :q {
    exit
}

function sshserver {
    ssh johnwilly@192.168.10.254
}

function neofetch {
    clear; fastfetch
}

function gituntrack {
    git rm --cached @args
}

function gits {
    git status @args
}

function gitd {
    git diff @args
}

function gita {
    git add . @args
}

function .. {
    Set-Location ..
}

function cd.. {
    Set-Location ..
}

function gitc {
    git commit -m @args
}

function gitdo {
    git diff origin @args
}

function gitf {
    git fetch @args
}

function gitbranchdates {
    git for-each-ref --sort=-committerdate '--format=%(refname:short) - %(committerdate:relative)' refs/heads/ @args
}

function gitsearch {
    git ls-files | rg @args
}

function cha {
    chezmoi add @args
}

function chr {
    chezmoi re-add @args
}

function chcd {
    chezmoi cd @args
}

Set-Alias -Name clr -Value Clear-Host

$env:EDITOR = 'nvim'


# =============================================================================
#
# Utility functions for zoxide.
#

# Call zoxide binary, returning the output as UTF-8.
function global:__zoxide_bin {
    $encoding = [Console]::OutputEncoding
    try {
        [Console]::OutputEncoding = [System.Text.Utf8Encoding]::new()
        $result = zoxide @args
        return $result
    } finally {
        [Console]::OutputEncoding = $encoding
    }
}

# pwd based on zoxide's format.
function global:__zoxide_pwd {
    $cwd = Get-Location
    if ($cwd.Provider.Name -eq "FileSystem") {
        $cwd.ProviderPath
    }
}

# cd + custom logic based on the value of _ZO_ECHO.
function global:__zoxide_cd($dir, $literal) {
    $dir = if ($literal) {
        Set-Location -LiteralPath $dir -Passthru -ErrorAction Stop
    } else {
        if ($dir -eq '-' -and ($PSVersionTable.PSVersion -lt 6.1)) {
            Write-Error "cd - is not supported below PowerShell 6.1. Please upgrade your version of PowerShell."
        }
        elseif ($dir -eq '+' -and ($PSVersionTable.PSVersion -lt 6.2)) {
            Write-Error "cd + is not supported below PowerShell 6.2. Please upgrade your version of PowerShell."
        }
        else {
            Set-Location -Path $dir -Passthru -ErrorAction Stop
        }
    }
}

# =============================================================================
#
# Hook configuration for zoxide.
#

# Hook to add new entries to the database.
$global:__zoxide_oldpwd = __zoxide_pwd
function global:__zoxide_hook {
    $result = __zoxide_pwd
    if ($result -ne $global:__zoxide_oldpwd) {
        if ($null -ne $result) {
            zoxide add "--" $result
        }
        $global:__zoxide_oldpwd = $result
    }
}

# Initialize hook.
$global:__zoxide_hooked = (Get-Variable __zoxide_hooked -ErrorAction Ignore -ValueOnly)
if ($global:__zoxide_hooked -ne 1) {
    $global:__zoxide_hooked = 1
    $global:__zoxide_prompt_old = $function:prompt

    function global:prompt {
        if ($null -ne $__zoxide_prompt_old) {
            & $__zoxide_prompt_old
        }
        $null = __zoxide_hook
    }
}

# =============================================================================
#
# When using zoxide with --no-cmd, alias these internal functions as desired.
#

# Jump to a directory using only keywords.
function global:__zoxide_z {
    if ($args.Length -eq 0) {
        __zoxide_cd ~ $true
    }
    elseif ($args.Length -eq 1 -and ($args[0] -eq '-' -or $args[0] -eq '+')) {
        __zoxide_cd $args[0] $false
    }
    elseif ($args.Length -eq 1 -and (Test-Path -PathType Container -LiteralPath $args[0])) {
        __zoxide_cd $args[0] $true
    }
    elseif ($args.Length -eq 1 -and (Test-Path -PathType Container -Path $args[0] )) {
        __zoxide_cd $args[0] $false
    }
    else {
        $result = __zoxide_pwd
        if ($null -ne $result) {
            $result = __zoxide_bin query --exclude $result "--" @args
        }
        else {
            $result = __zoxide_bin query "--" @args
        }
        if ($LASTEXITCODE -eq 0) {
            __zoxide_cd $result $true
        }
    }
}

# Jump to a directory using interactive search.
function global:__zoxide_zi {
    $result = __zoxide_bin query -i "--" @args
    if ($LASTEXITCODE -eq 0) {
        __zoxide_cd $result $true
    }
}

# =============================================================================
#
# Commands for zoxide. Disable these using --no-cmd.
#

Set-Alias -Name z -Value __zoxide_z -Option AllScope -Scope Global -Force
Set-Alias -Name zi -Value __zoxide_zi -Option AllScope -Scope Global -Force

# =============================================================================
#
# To initialize zoxide, add this to your configuration (find it by running
# `echo $profile` in PowerShell):
#
# Invoke-Expression (& { (zoxide init powershell | Out-String) })
