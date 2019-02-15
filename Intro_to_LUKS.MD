[![Guide Cover](https://i.imgur.com/LeYFR5i.png)]

-------------
## N.B: This is a self help note
--------------

[![Therap Logo](https://secure.therapservices.net/images/therapLogo-2016.0.0.png)](https://therapservices.net) [![Luks logo](https://guardianproject.info/wp-content/uploads/2011/02/luks-logo-cropped.png)](https://guardianproject.info/code/luks/)      -------  [![Wikipedia logo](https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Wikipedia-logo-v2-en.svg/135px-Wikipedia-logo-v2-en.svg.png)]

------------
## Just A Lil' Bit Background...
Just A Lil' Bit ....

## Plaintext
In cryptography, plaintext or cleartext is unencrypted information, as opposed to information encrypted for storage or transmission. 

## Ciphertext
In cryptography, ciphertext or cyphertext is the result of encryption performed on plaintext using an algorithm, called a cipher.

## Encryption
In cryptography, encryption is the process of encoding (creating ciphertext) a message (in Plaintext/cleartext) or information in such a way that only authorized parties can access it and those who are not authorized cannot.

## Encryption type: Symmetric key / Private Key / Secret Key
In symmetric-key schemes, the encryption and decryption keys are the same. Communicating parties must have the same key in order to achieve secure communication. That is, owner will encrypt the messege with a key and only the autorized party having the same key can unlock or decrypt the messege. 

[![Wikipedia logo](https://upload.wikimedia.org/wikipedia/commons/b/bc/Public_key_encryption_keys.png)]

## What is Full Disk Encryption?
Full disk encryption protects a disk in the event of theft or accidental loss. Whole disk encryption encrypts the entire disk including swap files, system files, and hibernation files. If an encrypted disk is lost, stolen, or placed into another computer (or use a Live ISO), the encrypted state of the drive remains unchanged, and only an authorized user can access its contents. In this document will achieve full disk encryption, using Linux kernel’s dm_crypt module, operating in LUKS.

### What is LUKS by the way?
LUKS (Linux Unified Key Setup) is the standard for Linux hard disk encryption. LUKS stores all information necessary to encrypt the partition the partition header, enabling the user to access his/her data seamlessly.

## Flow of Full Disk Encryption with LUKS

 ##### Before Full Disk Encryption:
 `Table-1:`
```
+--------------+-----------------------------------+
|              |      Block Device - Hard Drive    |
+--------------+-----------------------------------+
| Data Status: |             Cleartext             |
+--------------+-----------------------------------+
|  Partitions: |   /boot   |     /     |   swap    |
+--------------+-----------+-----------+-----------+
| Data Status: | Cleartext | Cleartext | Cleartext |
+--------------+-----------+-----------+-----------+

```

All Partition layout along with partition data is readable.
 ##### After Full Disk Encryption:
 `Table-2:`
```
+--------------+---------------------------------------+
|              |          Storage Block Device         |
+--------------+---------------------------------------+
| Partition    |      /boot     |   LUKS Block Device  |
+--------------+----------------+----------------------+
| Data Status: |    Plaintext   | Encrypted/Ciphertext |
+--------------+----------------+----------------------+
```
Here only `/boot` partion is in `plaintext` as the BIOS need to run the bootloader and only the boot loader is able to open the LUKS Block Device with appropriate `Passphrase` or `Secret key` to mount the file systems and run the operating system.


 ##### After opening the Full Disk Encrypted device:
 After opening the LUKS device with appropriate `passphrase` or `secret key` the partion will look like as in Table -1.
 Control flow of decryption of a full disk encrypted device is shown in the `Table-3:`
 ```
+--------------+------------------------------------+
|              |      Block Device - Hard Drive     |
+--------------+------------------------------------+
| Partitions:  |   /boot   | LUKS Block Device      |
+--------------+-----------+------------------------+
| File System: | XFS/EXT4  |          LUKS          |
+--------------+-----------+------------------------+
| Data Status: | Plaintext |  Encrypted/Ciphertext  |
+--------------+-----------+------------------------+
| After applying Passphrase prompt by bootloader    |
+---------------------------------------------------+
| Partitions:  | /boot     |     Logical Volumes    |
+--------------+-----------+------------------------+
| Data Status: | Plaintext |        Plaintext       |
+--------------+-----------+------------------------+
| File System: | XFS/EXT4  |           LVM          |
+--------------+-----------+------------------------+
|          After Mounting Logical Volumes           |
+---------------------------------------------------+
| Partitions:  | /boot     |      /     |    swap   |
+--------------+-----------+------------+-----------+
| File System: |  XFS/EXT4 | EXT4/btrfs |    swap   |
+--------------+-----------+------------+-----------+
| Data Status: | Plaintext | Plaintext  | Plaintext |
+--------------+-----------+------------+-----------+
 ```
 
### How LUKS Block Device looks like before applying passphrase
```
+--------------------------------------------------------------------------------------------+
|                                      Luks Block Device                                     |
+--------------------------------------------------------------------------------------------+
| Luks Header | Key0 | Key1 | Key2 | Key3 | Key4 | Key5 | Key6 | Key7 | User Encrypted Datea |
+-------------+------+------+------+------+------+------+------+------+----------------------+
```

You can see the `Luks Header` with the following command,
Assuming `/dev/sda5` is a LUKS device,
```
[localhost@localhost]# cryptsetup luksDump /dev/sda5
LUKS header information for /dev/sda5

Version:       	1
Cipher name:   	aes
Cipher mode:   	xts-plain64
Hash spec:     	sha256
Payload offset:	4096
MK bits:       	512
MK digest:     	7e 98 89 54 69 36 83 99 85 c4 86 a5 45 c3 b6 92 a5 cf 8f ac 
MK salt:       	32 51 17 97 7c b2 61 f7 37 8e 78 a1 e8 eb b4 6f 
               	ca 09 16 87 fd dd 83 f9 e2 1e e4 a2 70 62 1c 47 
MK iterations: 	53500
UUID:          	68b88379-3aef-4685-a732-8bedd29b63ca

Key Slot 0: ENABLED
	Iterations:         	430974
	Salt:               	ff fc 24 5f ba 81 e1 c4 23 98 49 b5 3a 0f 7f 39 
	                      	0c ce 8f 12 4c a0 03 cc b5 8f d2 a0 46 ea aa 47 
	Key material offset:	8
	AF stripes:            	4000
Key Slot 1: DISABLED
Key Slot 2: DISABLED
Key Slot 3: DISABLED
Key Slot 4: DISABLED
Key Slot 5: DISABLED
Key Slot 6: DISABLED
Key Slot 7: DISABLED

```

So you can see, you are able to store heighest `8 keys` to decrypt your LUKS device.

# Example 1 : Creating Encrypted USB Drive

Assuming your `USB` drive is `/dev/sdb`:

##### Creating a LUKS block device:
The following command will format the device `/dev/sdb` as luks device and will prompt for a passphrase:
```
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 luksFormat /dev/sdb
```

Where,
 - `--cipher` is a flag to select encryption algorithm here we have selected `aes-xts-plain64 `
 - `--key-size` is a flag to select passphrase size and here it is `512`. The possible key-sizes are limited by the cipher and mode used.
 - `--hash` is a flag to select which hash function to use. Here we have selected `sha512`
 - `luksFormat` is an option to format the device `/dev/sdb` as luks device.
 

##### Opening the LUKS block device:
The following command will open the block device we have just created,
```
cryptsetup luksOpen /dev/sdb usb
```
Where,
 - `luksOpen` is an option to open `/dev/sdb` as name `usb`
 


 ##### Creating partition
Here we will format the `usb` partition as `ext4`
```
mkfs.ext4 /dev/mapper/usb
```
 ##### mounting partition
 Now just mounting `/dev/mapper/usbstorage-storage` to a location will be enough to use it.
 
 ```
 mount /dev/mapper/usbstorage-storage /mnt/
 ```
  
##### Umount the USB
Unmount the storage partition
```
 umount -R /mnt/
 ```
Close the luks device

```
cryptsetup luksClose /dev/mapper/usbstorage-storage
```

##### To open the usb on different machine

###### Commandline :

```
cryptsetup luksOpen /dev/sdb usb
mount /dev/mapper/usb-storage
```

###### Graphical Mode:
After inserting USB, a dialog box will prompt for passphrase,

![Passphrase_prompt](https://i.imgur.com/qVTcsgV.png)


Then from file manager click on the `other filesystem` and you will probabily see the usb mount and clicking on the drive will result following image,

![Passphrase_prompt](https://i.imgur.com/YipxlvU.png)


# Example 2 : Creating Encrypted USB Drive with LVM

Assuming your `USB` drive is `/dev/sdb`:

##### Creating a LUKS block device:
The following command will format the device `/dev/sdb` as luks device and will prompt for a passphrase:
```
cryptsetup --cipher aes-xts-plain64 --key-size 512 --hash sha512 luksFormat /dev/sdb
```

Where,
 - `--cipher` is a flag to select encryption algorithm here we have selected `aes-xts-plain64 `
 - `--key-size` is a flag to select passphrase size and here it is `512`. The possible key-sizes are limited by the cipher and mode used.
 - `--hash` is a flag to select which hash function to use. Here we have selected `sha512`
 - `luksFormat` is an option to format the device `/dev/sdb` as luks device.
 

##### Opening the LUKS block device:
The following command will open the block device we have just created,
```
cryptsetup luksOpen /dev/sdb usb
```
Where,
 - `luksOpen` is an option to open `/dev/sdb` as name `usb`
 

##### Creating LVM :
The reason for creating Logical volume with LVM is to have flexibility on adding/removing, extending/reducing the partition size. And after decrypting luks block we can find the decrypted luks partition at `/dev/mapper`, in our case `/dev/mapper/usb`

First we will create Physical Volume with the command `pvcreate`. Then we will create volume group named `usbstorage` with command `vgcreate`. Then we can create multiple logical group and in this case only one logical group `storage`.

```
pvcreate /dev/mapper/usb
vgcreate usbstorage /dev/mapper/usb
```
```
lvcreate -l 100%FREE -n storage usbstorage
```
Where,
 - `-l` is to denote space to allocate on a single logical volume. Here, we have used `100%FREE` to allocate all spaces on volume group in the mentioned logical volume.
 - `-n`  is to provide name. Here, it is `storage` from volume group name `usbstorage`
  
 ##### Creating partition
Here we will format the `storage` partition as `ext4`
```
mkfs.ext4 /dev/mapper/usbstorage-storage
```
 ##### mounting partition
 Now just mounting `/dev/mapper/usbstorage-storage` to a location will be enough to use it.
 
 ```
 mount /dev/mapper/usbstorage-storage /mnt/
 ```
  
##### Umount the USB
Unmount the storage partition
```
 umount -R /mnt/
 ```
Close the luks device

```
cryptsetup luksClose /dev/mapper/usbstorage-storage
```

##### To open the usb on different machine

Commandline :
```
cryptsetup luksOpen /dev/sdb usb
mount /dev/mapper/usb-storage
```

Graphical Mode:

After inserting USB, a dialog box will prompt for passphrase,
![Passphrase_prompt](https://i.imgur.com/qVTcsgV.png)


Then from file manager click on the `other filesystem` and you will probabily see the usb mount and clicking on the drive will result following image,

![Passphrase_prompt](https://i.imgur.com/YipxlvU.png)


