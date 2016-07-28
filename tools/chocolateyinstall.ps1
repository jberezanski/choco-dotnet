$ErrorActionPreference = 'Stop'; # stop on all errors
$dotnetversion = "Latest"
$installDir = "c:\tools\dotnet"


$packageName = 'dotnetcore' # arbitrary name for the package, used in messages
$toolsDir = "$(Split-Path -parent $MyInvocation.MyCommand.Definition)"
$url = 'https://raw.githubusercontent.com/dotnet/cli/rel/1.0.0/scripts/obtain/dotnet-install.ps1' # download url


$packageParameters = $env:chocolateyPackageParameters

# Now parse the packageParameters using good old regular expression
if ($packageParameters) {
    $match_pattern = "\/(?<option>([a-zA-Z]+)):(?<value>([`"'])?([a-zA-Z0-9- _\\:\.]+)([`"'])?)|\/(?<option>([a-zA-Z]+))"
    $option_name = 'option'
    $value_name = 'value'

    if ($packageParameters -match $match_pattern ){
        $results = $packageParameters | Select-String $match_pattern -AllMatches
        $results.matches | % {
        $arguments.Add(
            $_.Groups[$option_name].Value.Trim(),
            $_.Groups[$value_name].Value.Trim())
    }
    }
    else
    {
        Throw "Package Parameters were found but were invalid (REGEX Failure)"
    }

    if ($arguments.ContainsKey("InstallDir")) {
        $installDir = $arguments["InstallDir"]
        Write-Host "Installing to custom InstallDir: '$installDir'"
    }
} else {
    Write-Debug "No Package Parameters Passed in"
}

$installDir = $installDir.Replace("/","\").TrimEnd("\")

$dninstall = Get-ChocolateyWebFile $packageName '$toolsDir\dotnet-install.ps1' $url
& $dninstall -version $dotnetversion -InstallDir "c:\tools\dotnet"


$path = [System.Environment]::GetEnvironmentVariable("PATH", [System.EnvironmentVariableTarget]::Machine)
$splits = $path.split(";")

if ($splits -notcontains $installDir) {
    $path += ";$installDir"
    [System.Environment]::SetEnvironmentVariable("PATH", $path, [System.EnvironmentVariableTarget]::Machine)

    write-host "dotnet installation dir '$installdir' addded to global PATH. Please refresh your environment variables (i.e. by calling 'RefresEnv' command)"
}