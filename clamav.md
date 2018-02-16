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


# Installing and configuring ClamAV on CentOS

Installing Clamav and clamtk [GUI frontend for calmav]

``` 
$ yum install clamav clamd
```
Starting and enabling **ClamAV** and **FreshClam** [Freshclam is a virus defination updater]
```
systemctl start clamav-daemon.service
systemctl enable clamav-daemon.service
systemctl start clamav-freshclam.service
systemctl enable clamav-freshclam.service
