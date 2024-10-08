# ls-win-core-affinity
set process core affinity in windows by powershell

Thanks to intel, when you trigger your build tasks then switch to watch videos, all the tasks are then scheduled on efficient cores. The only good thing is it doubles your video time.

This tool is to kill the rubbish time after trigger long time build task.

## Feature
1. set affinity to performance cores
2. set realtime to get most cpu time
3. install as a service and start on boot


## Other solution
### Power Options
You can also change the policy on how window schedule processes, by enable hidden option in Power Options, and different option will change the behavoir on how to schedule different cores.
```
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\93b8b6dc-0698-4d1c-9ee4-0644e900c85d 
HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Power\PowerSettings\54533251-82be-4824-96c1-47b60b740d00\7f2f5cfa-f10c-4823-b5e1-e93ae85f46b5
...
```
you can find more details by searching the keywords.
