param(
    [Alias("c")]
    [string]$ConfigFilePath = "$HOME\.caff.conf",
    [Alias("i")]
    [double]$Interval = 5,
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status

)

function Read-Config{
    $config = Get-Content -Path $ConfigFilePath | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
        $line = $_.Split('=')
        if ($line.Count -eq 2) {
            $keyword, $value = $line[0].Trim(), $line[1].Trim()
            $parts = $value.Split(',')
    
            $affinityValues = $parts[0].Split('+')
            $affinity = [uint64]0
            foreach ($value in $affinityValues) {
                $affinity += [uint64]1 -shl [uint64]$value
            }
    
            $priority = if ($parts.Length -gt 1) { $parts[1].Trim() } else { "Normal" }
    
            [PSCustomObject]@{
                Keyword = $keyword
                Affinity = $affinity
                Priority = $priority
            }
        }
    }
    return $config
}
function Main {
    echo "start"
    $config = Read-Config
    
    while ($true) {
    
        foreach ($item in $config) {
            $processes = Get-Process -Name $item.Keyword -ErrorAction SilentlyContinue
    
            foreach ($process in $processes) {
                $process.ProcessorAffinity = [int]$item.Affinity
                $process.PriorityClass = $item.Priority
            }
        }
    
        Start-Sleep -Seconds $Interval
    }
}

#
# for service install 
#
$serviceName    = 'FuckIntel'
$url            = 'https://nssm.cc/release/nssm-2.24.zip'
$zipFile        = "$Home\Downloads\nssm-2.24.zip"
$configFile     =  "$Home\.fuck_intel.conf"
$programDir     = "C:\Program Files\NSSM"
$nssmExePath    = "$programDir\nssm.exe"

function get_nssm{
    $nssm = (Get-Command nssm -ErrorAction SilentlyContinue).Source

    if ($nssm) {
        Write-Host "nssm is already installed at $nssm."
        return $nssm
    }

    $nssm = $nssmExePath
    if (-not $nssm){
        Write-Host "nssm not found. Downloading and extracting..."
    
        Invoke-WebRequest -Uri $url -OutFile $zipFile
    
        Remove-Item -Path "$destinationPath" -Force -Recurse

        Expand-Archive -Path $zipFile -DestinationPath .
    
        New-Item -ItemType Directory -Path $programDir

        Move-Item -Path "nssm-2.24\win64\nssm.exe" -Destination $nssmExePath

        Remove-Item -Path "$destinationPath" -Force -Recurse

    }
    return $nssm 
}

if( $Install ) {
    
    $serviceScriptPath = "$PSScriptRoot/caff.ps1"
    $arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}" -c {1}' -f $serviceScriptPath,$configFile
    $powershell = (Get-Command powershell).Source
    $nssm=get_nssm
    echo $nssm install $serviceName $powershell $arguments
    & $nssm install $serviceName $powershell $arguments

}
elseif ( $Uninstall ) {
    $service = Get-WmiObject -Class Win32_Service -Filter "Name='$serviceName'"
    $service.delete()
}
elseif ( $Start ) {
    Start-Service $serviceName
}
elseif ( $Stop ) {
    Stop-Service $serviceName
}
elseif ($Status ) {
    Get-Service $serviceName
}
else{
    Main
}

