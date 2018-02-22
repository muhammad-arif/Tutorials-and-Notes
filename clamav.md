# ClamAV Installing and configuration

[![N|Solid](https://www.clamav.net/assets/clamav-trademark.png)](https://www.clamav.net/assets/clamav-trademark.png)

# Installing and configuring ClamAV on Archlinux

Installing Clamav and clamtk [GUI frontend for calmav]
``` 
$ pacman -Sy clamav clamtk
```
Installing  `clamtk-gnome` and `thunar-sendto-clamtk` 
  - `clamtk-gnome` is a simple plugin for ClamTk to allow a right-click, context menu scan of files or folders in the Nautilus file manager.
  - `thunar-sendto-clamtk` is a simple plugin to allow a right-click, context menu scan of files or folders in Thunar.

If you use Thunar 
``` 
$ yaourt -S thunar-sendto-clamtk
```
If you use Nautilus or Gnome
``` 
$ yaourt -S clamtk-gnome
```
Starting and enabling **ClamAV** and **FreshClam** [Freshclam is a virus defination updater]
```
systemctl start clamav-daemon.service
systemctl enable clamav-daemon.service
systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service

``` 


# Installing and configuring **ClamAV** on CentOS

Installing Clamav and clamtk [GUI frontend for calmav]

``` 
$ yum install clamav clamd
```
Starting and enabling **ClamAV** and **FreshClam** [Freshclam is a virus defination updater]
```
systemctl start clamad.service
systemctl enable clamd.service
systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service
```

# Installing and configuring **ClamAV** on ubuntu

Installing Clamav and clamtk [GUI frontend for calmav]

``` 
$ sudo apt-get install clamav clamav-daemon clamav-freshclam
```
Starting and enabling **ClamAV** and **FreshClam** [Freshclam is a virus defination updater]

```
systemctl start clamav-daemon.service
systemctl enable clamav-daemon.service
systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service

```




## Configuring **clamAV** for daily check
Create script at `/etc/cron.daily/`  named `clamscan.daily` and making it executable:
```
$ touch /etc/cron.daily/clamscan.daily
$ chmod +x /etc/cron.daily/clamscan.daily
```
Adding follwoing content on `clamscan.daily`
```
#!/bin/bash
 
# email subject
SUBJECT="VIRUS DETECTED ON `hostname`!!!"
# Email To ?
EMAIL="me@domain.com"
# Log location
LOG=/var/log/clamav/scan.log
 
check_scan () {
 
    # Check the last set of results. If there are any "Infected" counts that aren't zero, we have a problem.
    if [ `tail -n 12 ${LOG}  | grep Infected | grep -v 0 | wc -l` != 0 ]
    then
        EMAILMESSAGE=`mktemp /tmp/virus-alert.XXXXX`
        echo "To: ${EMAIL}" >>  ${EMAILMESSAGE}
        echo "From: alert@domain.com" >>  ${EMAILMESSAGE}
        echo "Subject: ${SUBJECT}" >>  ${EMAILMESSAGE}
        echo "Importance: High" >> ${EMAILMESSAGE}
        echo "X-Priority: 1" >> ${EMAILMESSAGE}
        echo "`tail -n 50 ${LOG}`" >> ${EMAILMESSAGE}
        mailx -t < ${EMAILMESSAGE}
    fi
 
}
 
clamscan -r / --exclude-dir=/sys/ --quiet --infected --log=${LOG}
 
check_scan
``` 
