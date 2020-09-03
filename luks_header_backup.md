# Luks Devices Info Bakcup

-------------
[![Luks logo](https://guardianproject.info/wp-content/uploads/2011/02/luks-logo-cropped.png)](https://guardianproject.info/code/luks/)      -------  [![Wikipedia logo](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Wikipedia-logo-v2-en.svg/135px-Wikipedia-logo-v2-en.svg.png)]

------------
#### Script Name: luks-header-backup.sh
#
#
#### Purpose:

##### Taking following info into several files:

###### Following informations are redirected into the file named `luks_essential.info`,
- Partition Information [Output of the command `fdisk`]

- Block Information [Output of the command `lsblk`]

- Partition Type Information [Output of the command `blkid`]

- FSTAB information [Output of the `/etc/fstab`]

- Key details of the LUKS control devices [Output of the command `dmsetup table --target crypt --showkeys`]
 
- LUKS Header information [Output of the command `cryptsetup luksDump`]
 
###### Following informations are redirected into the file named as `header_(partition name).bin`. 
E.G: `header_sdd1.bin, header_sdd2.bin, header_sdd3.bin`

- First 2MB `binary dump` of the LUKS devices, which consist of the LUKS header
 
###### Following informations are redirected into the file named as `(luksdeviceid)-key.bin`. 
E.G: `luks-93a39a43-7237-4ffb-9d3c-24654a464a6f4-key.bin`
- Binary version of LUKS keys of the LUKS devices

#### Reason:

###### Reason for taking Partition info,

- In case of luks header corruption partiotn info may get lost. In that case the mounted information will get usefull

###### Reason for taking Key info and Key binary,

- In the case of loosing passsphrase of luks devices, we may able to add new key with the binary version of the keys,
- To get the information of the keys encryption algorithm we took keys information with the `blkid`

How to :
```
cryptsetup luksAddKey --master-key-file=<master-key-file> <luks device>
```
Example:
```
cryptsetup luksAddKey --master-key-file=luks-93a39a43-7237-4ffb-9d3c-24654a464a6f4-key.bin /dev/sdd3
```

###### Reason for taking luks header dump,

- Header file might corrupted due to various reason which results inacceablity of the device. 
- In case of any kind of disaster we can recover the header file with the backed up dumps.

How to:
```
cryptsetup --header <file> luksOpen <device> </dev/mapper/ -name>
or
cryptsetup luksHeaderRestore --header-backup-file <file> <device>
```
Example:
```
cryptsetup --header header_sdd1.bin luksOpen /dev/sdd1
or
cryptsetup luksHeaderRestore --header-backup-file header_sdd1.bin /dev/sdd1
```
