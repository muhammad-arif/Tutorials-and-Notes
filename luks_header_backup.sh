#!/usr/bin/env bash

# Declaring Variables
DIR="/tmp/luks"
LDIR="/dev/mapper/luks-*"
FILE1="luks_essential.info"
FILE2="luks_header_dump.bin"
FILE3="luks_keys.bin"
FSTAB="/etc/fstab"
BCKFL="luks_backup.gz"
TMP="/tmp/"
LKS="luks/"
# Function for performing Sanity check
die() { printf '\n\033[0;31m%s \033[0m\n\n' "$1" ; exit 1; }

# Function for performing Successful execution
success() { printf '\n\033[0;32m%s \033[0m\n\n' "((Success))" ; return 0;}

# BASIC VALIDATION:
################################## STEP - 1 #######################################

#+ Argument validation
[ $# == 0 ] || die "This script does not accept any arguemnt. Just run the script as root. || STEP -1 ||"


#++ User ID Validation
[ "$EUID" == "0" ] || die "Please run this script as root. || STEP -1 ||"

#+++ Checking if there is a crypt Device 

#++++ Counting crypt device
printf "Looking for crypt device...."
CNT="$(blkid | grep 'TYPE="crypto_LUKS"' | awk -F ":" '{print $1}' | wc -l)"
[ $CNT != 0 ] && success || die "No Crypt Device Found. || STEP -1 ||"


# Creation of Directory:
################################## STEP - 2 #######################################

#+ Creating a temporary directory `luks` on '/tmp'
printf "\nCreating Directory \'$DIR\'\n"
mkdir $DIR && success || die "Cannot Create Directory. || STEP -2 ||"

#++ Changing direcotry to `/tmp`
printf "\nChanging Directory to $DIR\n"
cd $DIR && success || die "Cannot change to the newly created directory. || STEP -2 ||"
printf "\nCurrent Directory is: $(pwd)\n "


# Getting Necessary info and redirecting to `/tmp/luks/luks_essential.info`:
################################## STEP - 3 #######################################

printf "\nGetting Necessary info and redirecting to '/tmp/luks/luks_essential.info'\n"

#+ Creating `/tmp/luks_essential.info`
touch $FILE1

printf "||||| Printing LUKS Essential Information |||||\n\n" >> $FILE1

printf "\n||||| Partition info ||||||\n" >> $FILE1
fdisk -l >> $FILE1 2> /dev/null || die "fdisk is not working properly. || STEP -3 ||"

printf "\n||||| Block Information ||||||\n\n" >> $FILE1
lsblk >> $FILE1 || die "lsblk is not working properly. || STEP -3 ||"

printf "\n||||| Partition Type info ||||||\n\n" >> $FILE1
blkid >> $FILE1 || die "blkid is not working properly. || STEP -3 ||"

printf "\n||||| FSTAB info ||||||\n\n" >> $FILE1
cat $FSTAB >> $FILE1 || die "Cannot Read or Redirect fstab. || STEP -3 ||"

printf "\n||||| Key Information LUKS Control Devices ||||||\n\n" >> $FILE1
dmsetup table --target crypt --showkeys $LDIR >> $FILE1 || die "No Device found. || STEP -3 ||"

printf "\n||||| LUKS Header Information Dump ||||||\n\n" >> $FILE1
for i in $(blkid | grep "crypto_LUKS" | awk -F ":" '{print $1}' ); do cryptsetup luksDump $i;done >> $FILE1

success
################################## STEP - 4 #######################################
# Creating backup of LUKS Header and the binary form of the keys of the luks devices

printf "\nCreating backup of LUKS Header of All LUKS Devices\n"
#+ Creating LUKS header backup . File name will be like, header_sda5.bin, header_vg1-var.bin, etc.
for i in $(blkid | grep 'TYPE="crypto_LUKS"' | awk -F ":" '{print $1}'); do cryptsetup luksHeaderBackup $i --header-backup-file $DIR/header_$(echo $i | grep -oE '[0-9A-Za-z-]+$').bin ;done && success || die "Cannot Redirect LUKS Header to $DIR. || STEP -4 ||"

printf "\nGenerating Binary version of the keys.....\n"
#++ Generating Key of Luks devices and converting to binary. File name will be like, luks-*-pass.bin
for i in $(ls $LDIR); do dmsetup table --target crypt --showkeys $i | sed -E -n 's/.*crypt\s[a-zA-Z0-9-]+\s([a-f0-9]+)\s.*$/\1/p' | sed 's/\([0-9A-F]\{2\}\)/\\\\\\x\1/gI' | xargs printf > $DIR/$(echo $i | grep -oE '[0-9A-Za-z-]+$')-key.bin ; done && success || die "No Device found. || STEP -4 ||"


################################## STEP - 4 #######################################
# Finalization

#+ Showing Final Content
printf "\nShowing Final Content of \'$DIR\'......\n$(ls -1 $DIR)\n"

#++ Creating Archive
cd $TMP && success || die "Cannot Change directory to $TMP"
printf "\nCreating Archive....\n"
tar -zcvf $BCKFL $LKS && success || die "Cannot Create tar Archive || STEP -4 ||"

#+++ Cleening up 
printf "\nGenerating HASH value of the archive....\n"
md5sum $TMP$BCKFL && success

rm -rf $DIR

printf "\nChecking Newly Created Archive\n"
ls -la $TMP$BCKFL && success || die "No Archive File found\n:( :( :( :(\nWhat The Hell????"

#++++
printf "\n\t\t\!!!!!!!!!!!!!!!!   DISCLAIMER   !!!!!!!!!!!!!!!!!!!
        \n\t\tAnyone  have  access  to  the  \'$TMP$BCKFL\' 
        \n\t\tfile   can   access   to    your    drive    without
        \n\t\tpassphrase   with   the  help  of  the   information
        \n\t\tkept   in   the   archive.   Thanks. \n\n"
exit 0
