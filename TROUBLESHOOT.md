# This readme file serve you a basic troubleshooting guide for your system.

- First of all 

```shell
    sudo apt update ; sudo apt upgrade
```

- `apt update` is like updating a catalog of available software, letting your system know what's new.
- `apt upgrade` is like actually going and getting those new versions of the software you already have installed.

## Basic Things to do:

- Here is some basic thing which you must do to improve performance 
1. Do basic clean
    
    ```shell
    sudo apt clean
    sudo apt autoremove
    sudo journalctl --vacuum-time=3d
    ```
   
2. Close unwanted start-up

    We will use the tool `Stacer`
    ```shell
    sudo apt-get install stacer
    ```

    - `Stacer` is a good GUI tool to discover your system files
    - You can clean trash, unwanted packages and unwanted snaps too...
    - Just install it and explore it

3. Install preloader in your machine

    ```shell
    sudo apt install preload
    ```
   - How Preload Works:
     - Monitors Usage: Preload runs in the background, observing which applications you use and how often.
     - Predicts Needs: Based on your usage patterns, it predicts which programs you will launch next.
     - Caches to Memory: It pre-loads the binaries and dependencies of these frequently used applications into your system's RAM.
     - Speeds Up Startup: By having the application's data already in memory, it can start much faster when you open it.

- To get a **quick look of machine** run below command

```shell
  hostnamectl
```

- The output looks like :point_down:

        Static hostname:
        Icon name: 
        Chassis: laptop
        Machine ID: 
        Boot ID: 
        Operating System: Ubuntu x.x.x             
        Kernel: Linux x.x.x
        Architecture: 
        Hardware Vendor: 
        Hardware Model: 
        Firmware Version: 
        Firmware Date: 
        Firmware Age:
---

- Let's check when the last time the package list was updated.

```shell
    ls -l /var/cache/apt/pkgcache.bin
```
- The output looks like :point_down:
        
        -rw-r--r-- 1 root root 59405319 Oct  3 15:04 /var/cache/apt/pkgcache.bin
- Look the time stamp `Oct  3 15:04`, it indicates last time when packages was updated.
--- 

- To check the **Systemd Status Summary**

```shell
    systemctl status
```
- The output looks like :point_down:

        <user>-<laptop>
        State: 
        Units: n loaded (incl. loaded aliases)
         Jobs: 0 queued
       Failed: 2 units
        Since: 
      systemd: 255.4-1ubuntu8.5
       CGroup: /
               ├─init.scope
               │ └─1 /sbin/init splash
               ├─system.slice
               │ ├─ModemManager.service
               │ │ └─1003 /usr/sbin/ModemManager
               │ ├─NetworkManager.service
               │ │ └─926 /usr/sbin/NetworkManager --no-daemon
               │ ├─accounts-daemon.service

- Shows an overview of the system's initialization state. Look for services that have failed (red status) or are degraded, which could indicate a software conflict or driver issue.
- Press `q` to direct exit from output.  
---

- **Real-time I/O by Process**

```shell
    sudo iotop -oP
```

- When you run the above command real-time I/O process shows in terminal to exit from this press `q`.
- Displays the processes currently using the most disk I/O, sorted by usage (-o). 
- Use this when the system is lagging to see if an IDE background task (indexing, search) is maxing out the disk
---

- **Disk Partition Type** 

```shell
    lsblk -o NAME,FSTYPE,SIZE,MODEL,ROTA
```

- The ROTA column (rotational) is key: 0 means SSD (fast), 1 means HDD (slow). 
- This quickly identifies if a machine is running on a slow drive.

- **Filesystem Read/Write Errors**

```shell
    sudo badblocks -sv /dev/<sdX> #  (replace /dev/sdX with the correct disk, e.g., /dev/sda)
```

- scanning may took long time it depends on disk size.
- (CAUTION: Read-only check) Runs a read-only scan for bad blocks on a disk partition. This helps confirm if the disk itself is failing, causing I/O delays.
---

- **I/O Wait (CPU)**

```shell
    iostat -cx 1 5
```

- The output looks like :point_down: 

        avg-cpu:  %user   %nice %system %iowait  %steal   %idle
        14.79    0.02    3.82    0.74    0.00   80.63

        Device            r/s     rkB/s   rrqm/s  %rrqm r_await rareq-sz     w/s     wkB/s   wrqm/s  %wrqm w_await wareq-sz     d/s     dkB/s   drqm/s  %drqm d_await dareq-sz     f/s f_await  aqu-sz  %util
        dm-0             1.33     73.57     0.00   0.00    1.42    55.16    5.51     51.44     0.00   0.00    2.84     9.34    0.00      0.00     0.00   0.00    0.00     0.00    0.00    0.00    0.02   0.18
        .
        .
        .

- Watch the `%iowait` column over **5 seconds**. 
- If this value is consistently above 10%, the CPU is sitting idle, waiting for the disk to respond, indicating an I/O bottleneck.

- **Disk Latency & Utility**

```shell
    iostat -dx 1 5
```

- Look at the disk metrics (/dev/sda or similar): • `await` (ms): Average I/O wait time. 
- High values (e.g., >20ms for SSD) indicate severe disk latency. • `%util`: Disk utilization. 
- If this is consistently > `80%`, the disk is fully saturated and cannot handle more requests.


- **I/O Scheduler Check**

```shell
    cat /sys/block/sda/queue/scheduler
```

- Diagnostic: Identifies the active I/O scheduler. 
- For SSDs, the optimal scheduler is often none or mq-deadline. 
- If it shows cfq (older kernel) or bfq, performance may be suboptimal.
---

-  **Memory, Swap, and Out-of-Memory (OOM) Management**

- **Memory/Swap/I/O Summary**

```shell
    vmstat 1 5
```

- Provides an overall system health snapshot every second. 
- Look at: • `si/so (Swap In/Out)`: If these columns show frequent, non-zero values, the system is actively thrashing, swapping memory to and from the disk. which causes major performance hits. 
- `wa (I/O Wait)`: Confirms if the thrashing is causing a CPU bottleneck.

- **Swappiness Setting**

```shell
    cat /proc/sys/vm/swappiness
```

- Diagnostic: Shows how aggressively the kernel uses swap. 
- The default is `60`, which is high. 
- A value of `10` or `20` is better for systems with large RAM `(16GB+)` to keep memory unused before swapping.

- **OOM Killer (Out-Of-Memory)** 
- To identify which process was killed, users can search logs using commands like 

```shell 
    dmesg -T | grep -i "killed process" 
    #or
    grep -i "oom-killer" /var/log/syslog
```

---