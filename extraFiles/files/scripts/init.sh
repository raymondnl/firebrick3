#!/bin/dash
#
# Firebrick main script
# edit 17/06/2013 - Lee Tobin
# last edit 03-08-2014 - Raymond van den Heuvel
NAME=init
DESC="FIREBrick INIT"

case "$1" in
    start)
    #Setting Base variables
    export devel=0;

    #Checking whether we are running in QEMU
    dmiInfo=$(dmesg | grep -i DMI:);
    result=$(echo $dmiInfo | cut -d ' ' -f 4);
    if [ "$result" = "QEMU" ] ; then
      export runningvirtual=1
    else
      export runningvirtual=0 
    fi

    #Include functions
    . /scripts/functions.sh

    #--- Check the LCD device nodes
    #Get LCD location on USB bus
    lcdnodeinfo=$(lsusb | grep 0403:c630)
    #Tokenise on spaces
    IFS=' '
    set --  $lcdnodeinfo
    lcdnodedir=/dev/bus/usb/$2
    lcdnode=$lcdnodedir/${4%?}
    echo Found LCD on $lcdnode

    if [ ! -e $lcdnode ] ; then 

	if [ ! -d $lcdnodedir ]; then
		#create dev dir
		mkdir -p $lcdnodedir
	fi
	#if test -f output/target/etc/init.d/S40network; then rm output/target/etc/init.d/S40network ; fi
	if [ ! -f $lcdnode ]; then
		#Get major and min dev ids
		deviceline=$(dmesg | grep 'idVendor=0403' | tail -1)
		set -- $deviceline
		cd /sys/bus/usb/devices/${4%?}

		majnum=$(grep MAJOR uevent)
		minnum=$(grep MINOR uevent)
		#token on "="
		IFS='='
		set -- $majnum
		majnum=$2
		set -- $minnum
		minnum=$2

		#make the device node
		mknod $lcdnode c $majnum $minnum
		
		lcd c
		lcd o 190
		
		cd /scripts
	fi
   fi

   lcd c
   lcd o 190
   lcd g 0 0
   lcd p "Mounting storage"

   #alias tweaks
   #remove the human readable flag
   alias df='df'

   #Check for storage and mount storage
   #Storage check
   if [ $runningvirtual = 1 ] ; then
	export storageDisk1=$(ls -la /sys/block | grep ata. | grep host0 | grep target0:0:0 | grep -o sd. | tail -1)
	export storageDisk2=$(ls -la /sys/block | grep ata. | grep host0 | grep target0:0:1 | grep -o sd. | tail -1)
   else
	export storageDisk1=$(ls -la /sys/block | grep ata. | grep host2 | grep -o sd. | tail -1)
	export storageDisk2=$(ls -la /sys/block | grep ata. | grep host3 | grep -o sd. | tail -1)
   fi
   # check the situation with storage
   if [ ${#storageDisk1} -gt 2 ] && [ ${#storageDisk2} -gt 2 ] ; then #RAID
	export storageDevice="/dev/md0"
        mdadm --assemble $storageDevice /dev/$storageDisk1 /dev/$storageDisk2
        sleep 2
        fdisk -l
	mount $storageDevice"p1" /firestor
   elif [ ${#storageDisk1} -gt 2 ]; then #single disk
	export storageDevice="/dev/${storageDisk1}"

        result=$(mdadm --misc --examine /dev/$storageDisk1);
        if [ "$result" = "mdadm: No md superblock detected on /dev/"$storageDisk1 ] ; then
           export storageDevice="/dev/md0"
           mdadm --assemble $storageDevice /dev/$storageDisk1
           sleep 2
           fdisk -l
           mount $storageDevice"p1" /firestor
        else
          mount dev/$storageDisk1 /firestor
        fi
   elif [ ${#storageDisk2} -gt 2 ]; then #single disk
	export storageDevice="/dev/${storageDisk2}"
        result=$(mdadm --misc --examine /dev/$storageDisk2);
        if [ "$result" = "mdadm: No md superblock detected on /dev/"$storageDisk2 ] ; then
           export storageDevice="/dev/md0"
           mdadm --assemble $storageDevice /dev/$storageDisk2
           sleep 2
           fdisk -l
           mount $storageDevice"p1" /firestor
        else
           mount dev/$storageDisk2 /firestor
        fi
   else
	#No disks!!!
	export storageDevice=""
   fi

   lcd g 0 1
   lcd p "Storage found on:"
   lcd g 3 2
   lcd p "$storageDevice"
   echo Storage found on:$storageDevice


   SYSTEMCONFIGFOLDER="/firestor/.firebrick/config";
   SYSTEMCONFIGFILE=$SYSTEMCONFIGFOLDER"/system.cfg";
   if [ ${#TODAYFOLDER} -eq 0 ]; then
      TODAYFOLDER=`date +%d-%m-%Y`;
   fi
   if [ -f $SYSTEMCONFIGFILE ]; then
      LANGUAGE="$(getConfigItem "LANGUAGE" $SYSTEMCONFIGFILE)"; 
      FIRESTOR="$(getConfigItem "FIRESTOR" $SYSTEMCONFIGFILE)";
      FBLOGBASE="$(getConfigItem "FBLOGBASE" $SYSTEMCONFIGFILE)";
      FBSTATUSLOCATION="$(getConfigItem "FBSTATUSLOCATION" $SYSTEMCONFIGFILE)";
      SYSTEMLOGFILE=$FBLOGBASE"/"$TODAYFOLDER"/system.log";
   else
      LANGUAGE="en_GB"; 
      FIRESTOR="/firestor";
      FBLOGBASE="/firestor/.firebrick/logs";
      FBSTATUSLOCATION="/firestor/.firebrick/status";
      SYSTEMLOGFILE="/system.log";
   fi

   lcd g 0 3
   lcd p "Running basic checks"

   if isMounted $FIRESTOR; then
      #Check if logging location is available   
      logDirectoryExist

      #Check if system configuration file exists
      systemConfigFileExist

      #Delete opencase if is it exists after a restart of the firebrick. This is an unclean shutdown/restart.
      if [ -f "$FBSTATUSLOCATION/OPENEDCASE" ]; then
         echo $(__ "%s: %s the OPENCASE file was found, there has been an unclean shutdown when a case was opened!!" "$(date +%X)" "LOCALSYSTEM") >> $SYSTEMLOGFILE
         rm -f "$FBSTATUSLOCATION/OPENEDCASE"
      fi

      if [ -f "$FBSTATUSLOCATION/FBSTARTED" ]; then
         starttime=$(date -r "$FBSTATUSLOCATION/FBSTARTED");
         lcd g 0 4
         lcd p "Unclean shutdown!"
         echo $(__ "%s: %s the FBSTARTED file was found, there has been an unclean shutdown after being started @ %s firebrick time!!" "$(date +%X)" "LOCALSYSTEM" "$starttime") >> $SYSTEMLOGFILE
         rm -f "$FBSTATUSLOCATION/FBSTARTED"
         touch "$FBSTATUSLOCATION/FBSTARTED"
      else
         echo $(__ "%s: %s system started after clean shutdown!!" "$(date +%X)" "LOCALSYSTEM") >> $SYSTEMLOGFILE
         touch "$FBSTATUSLOCATION/FBSTARTED"
      fi
   fi

   fbIP=$(getIP "eth[0-2]");
   sleep 5

   lcd c
   lcd g 0 0
   lcd p "FIREBrick ready"
   lcd g 0 2
   lcd p "Browse to:"
   lcd g 0 3
   lcd p $fbIP
   ;;
stop)
   echo -n "Not doing anything"
   ;;
restart)
   echo "Not doing anything"
   #$0 stop
   #$0 start
   ;;
reload)
   echo -n "Not doing anything "
   ;;
*)
   echo "Usage: $0 {start}"
   exit 1
   ;;
esac

exit 0

