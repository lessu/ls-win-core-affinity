# ls-win-core-affinity
set process core affinity in windows by powershell

Thanks to intel, when you trigger your build tasks then switch to watch videos, all the tasks are then scheduled on efficient cores. The only good thing is it doubles your video time.

This tool is to kill the rubbish time after trigger long time build task.

## Feature
1. set affinity to performance cores
2. set realtime to get most cpu time
3. install as a service and start on boot

## Install

- Run Powersell with Administrator permission

```
# it will download NSSM to C:\Program Files\NSSM, NSSM is a wrapper for this ps1 script
.\caff.ps1 -Install
```

- if you have already installed NSSM, you can install by 

```
.\caff.ps1 -Install -NssmPath <YOUR_NSSM_PATH>

```

- if you want to remove the service (Admin is required)
```
.\caff.ps1 -UnInstall
```

- check the status by
```
.\caff.ps1 -Status
```


## Usage
### service
- start/stop (Admin is required)

```
.\caff.ps1 -Start

.\caff.ps1 -Stop
```
### Cli
```
# use default config file $HOME/.caff.conf
.\caff.ps1 

# use specified config file
.\caff.ps1 -c <YOUR_CONFIG_FILE>

# scan processes every 1s, default 5s
.\caff.ps1 -i 1
```

### Config file
default configure file path is `$HOME/.caff.conf`
example 
```
# process=affinity, priority"
# get process name by, open task manager right click on column, select process Name to show"
# affinity: 0+2 mean core0 and core2"
# priority: idle, low, below normal, normal, above normal, high priority, realtime"

explorer=0+2+4+6,realtime
```

Notice if configure file is changed, please restart service

## Other solution
### Power Options
You can also change the policy on how window scheduler processes, by enable hidden option in Power Options
```bat
:: enable advanced power setting
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5" /v Attributes /t REG_DWORD /d 2 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\93b8b6dc-0698-4d1c-9ee4-0644e900c85d" /v Attributes /t REG_DWORD /d 2 /f
reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\bae08b81-2d5e-4688-ad6a-13243356654b" /v Attributes /t REG_DWORD /d 2 /f

```
different option will change the behavoir on how to schedule different cores.( You can open Power Options to change the policy then )

you can find more details by searching the keywords.
