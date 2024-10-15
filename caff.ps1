param(
    [Alias("c")]
    [string]$ConfigFilePath = "$HOME\.caff.conf",
    [Alias("i")]
    [double]$Interval = 5,
    # install patameter
    [string]$NssmPath,
    [switch]$Install,
    [switch]$Uninstall,
    [switch]$Start,
    [switch]$Stop,
    [switch]$Status

)
$configTemplate = @("# process=affinity, priority",
                    "# get process name by, open task manager right click on column, select process Name to show"
                    "# affinity: 0+2 mean core0 and core2",
                    "# priority: idle, low, below normal, normal, above normal, high priority, realtime",
                    "# eg:",
                    "# explorer=0+2+4+6,realtime")
                    
function Read-Config{

    if ( -not (Test-Path $ConfigFilePath) ){
        New-Item -ItemType File -Path $ConfigFilePath -Force | Out-Null
        Add-Content -Path $ConfigFilePath -Value $configTemplate
    }

    $ret = Get-Content -Path $ConfigFilePath | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
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
    return $ret
}

function Main {
    echo "start"
    Write-Host $config
    $config = Read-Config
    Write-Host $config

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
$serviceName    = 'CoreAffinity'
$url            = 'https://nssm.cc/release/nssm-2.24.zip'
$zipFile        = "nssm-2.24.zip"
$programDir     = "C:\Program Files\NSSM"
$nssmExePath    = "$programDir\nssm.exe"
$unzipDir       = "nssm-2.24"
function get_nssm{
    # use the value specified in arg
    if( $NssmPath ){
        return $NssmPath
    }

    $nssm = (Get-Command nssm -ErrorAction SilentlyContinue).Source

    if ($nssm) {
        Write-Host "nssm is already installed at $nssm."
        return $nssm
    }

    $nssm = $nssmExePath
    if (-not (Test-Path $nssm)){
        if ( -not (Test-Path $unzipDir)) {
            Write-Host "nssm not found. Downloading and extracting..."
            Invoke-WebRequest -Uri $url -OutFile $zipFile
            Expand-Archive -Path $zipFile -DestinationPath .
        }

        try{
            New-Item -ItemType Directory -Path $programDir -ErrorAction Stop | Out-Null
            Move-Item -Path "$unzipDir\win64\nssm.exe" -Destination $nssmExePath -ErrorAction Stop | Out-Null
        }catch{
            # you don't have permission maybe
            Write-Host "Fatal: can not move nssm, please run this by admin user again"
            $nssm = ""
        }

        # remove tmp file
        # Remove-Item -Path "$unzipDir" -Force -Recurse

    }
    return $nssm 
}

if( $Install ) {
    
    $serviceScriptPath = "$PSScriptRoot/caff.ps1"
    $arguments = '-ExecutionPolicy Bypass -NoProfile -File "{0}" -c {1}' -f $serviceScriptPath,$configFilePath
    $powershell = (Get-Command powershell).Source
    $nssm=get_nssm
    if ( -not $nssm){
        Write-Host "Fatal: failed to get nssm"
        exit -1
    }
    Write-Host $nssm install $serviceName $powershell $arguments
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

