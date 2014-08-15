#!/bin/dash
#Load definitions of functions from external file(s)
. ./functions.sh

#Prepare for output to browser
echo Content-type: text/html
echo ""

# Dit moet variable gemaakt worden middels init script gebasseerd op een settings bestand
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
  TEXTDOMAINDIR="$(getConfigItem "TEXTDOMAINDIR" $SYSTEMCONFIGFILE)";
  AccountInfoFile="$(getConfigItem "AccountInfoFile" $SYSTEMCONFIGFILE)";
  ModulesInfoFile="$(getConfigItem "ModulesInfoFile" $SYSTEMCONFIGFILE)";
  URLENCODE="$(getConfigItem "URLENCODE" $SYSTEMCONFIGFILE)";
  URLDECODE="$(getConfigItem "URLDECODE" $SYSTEMCONFIGFILE)";
  USBMODSLEEPSTEP="$(getConfigItem "USBMODSLEEPSTEP" $SYSTEMCONFIGFILE)";
  USBMODMAXWAIT="$(getConfigItem "USBMODMAXWAIT" $SYSTEMCONFIGFILE)";
  USBMODSYSDIRECTORY="$(getConfigItem "USBMODSYSDIRECTORY" $SYSTEMCONFIGFILE)";
  USBMODFINDDEV="$(getConfigItem "USBMODFINDDEV" $SYSTEMCONFIGFILE)";
  devel="$(getConfigItem "devel" $SYSTEMCONFIGFILE)";
  runningvirtual="$(getConfigItem "runningvirtual" $SYSTEMCONFIGFILE)";
  FBMODULELOCATION="$(getConfigItem "FBMODULELOCATION" $SYSTEMCONFIGFILE)";
  USBMODMODULELOCATION="$(getConfigItem "USBMODMODULELOCATION" $SYSTEMCONFIGFILE)";

else
  LANGUAGE="en_GB"; 
  FIRESTOR="/firestor";
  FBLOGBASE="/firestor/.firebrick/logs";
  FBSTATUSLOCATION="/firestor/.firebrick/status";
  SYSTEMLOGFILE="/system.log";
  TEXTDOMAINDIR="/fblocale";
  USBMODSLEEPSTEP="1s";
  USBMODMAXWAIT=10;
  USBMODSYSDIRECTORY="/sys/block";
  USBMODFINDDEV="sd[a-d]";
  devel=0;
  runningvirtual=0;
  FBMODULELOCATION="/firestor/.firebrick/modules"
  USBMODMODULELOCATION="/mnt/modules"
  URLENCODE="/var/admin/cgi-bin/urlencode.sed";
  URLDECODE="/var/admin/cgi-bin/urldecode.sed";
fi

# Dit moet variable gemaakt worden middels init script gebasseerd op een settings bestand

#Declaring (Global) Variables, which we will use in functions and logging
TEXTDOMAIN="ajax.cgi";
scriptFileName=""
contentType=""
httpHost=""
httpReferer=""
httpUserAgent=""
remoteAddress=""
requestMethod=""
requestUri=""
scriptPath=""
queryString=""

# Check if we received a command

parseAndFillVariables

if ! command="$(getNamedValue $queryString "command")"; then
    return_message "CHECK_INPUT";
else
  if [ "$command" != "getstorageinfo" ] && [ "$command" != "initstorage" ]; then
     #Perform pre-work checks
     preFlightCheck
     #If we ended up here the preflightcheck was ok
     #let's start logging
     echo $(__ "%s: %s called through %s by %s" "$(date +%X)" "$requestUri" "$httpReferer" "$remoteAddress"  ) >> $SYSTEMLOGFILE
  fi
  case $command in
    "newcase") #Get the required variables from the QUERY_STRING
         if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
         if ! casedescr="$(getNamedValue $queryString "casedescr")"; then return_message "CHECK_INPUT"; fi
         if ! caseinvest="$(getNamedValue $queryString "caseinvest")"; then return_message "CHECK_INPUT"; fi
              
         checkcaseexist $caseid
         # Case does not exist if we ended up here
         mkdir $FIRESTOR"/"$caseid
         if [ ! -d $FIRESTOR"/"$caseid ]; then
             #The case directory was not created, we seem to have a problem
             echo $(__ "%s: %s could not create case %s" "$(date +%X)" "$remoteAddress" "$caseid") >> $SYSTEMLOGFILE
             return_message "CASE_NOT_CREATED";
         fi
         #All good, Case directory creates, now write a case configuration file
         echo $(__ "%s: %s case %s created" "$(date +%X)" "$remoteAddress" "$caseid") >> $SYSTEMLOGFILE
         mkdir $FIRESTOR"/"$caseid"/conf"
         echo "Section:Case-BEGIN" > $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "CaseID="$(echo $caseid | sed -f decode.sed) >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "Description="$(echo $casedescr | sed -f decode.sed) >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "Investigator="$(echo $caseinvest | sed -f decode.sed) >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "CreatedOn="`date +%x` >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "CreatedAt="`date +%X` >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "Section:Case-END" >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "" >> $FIRESTOR"/"$caseid"/conf/case.conf"
               
         groupID=$(allocateID "GUID");
         userID=$(allocateID "UID");
         #All good, updating configuration and write this information to the assigned numbers file
         modifyConfig "GID_LASTASSIGNED" $groupID $SYSTEMCONFIGFILE
         modifyConfig "UID_LASTASSIGNED" $userID $SYSTEMCONFIGFILE
               
         echo $caseid",case,usr"$caseid","$userID",grp"$caseid","$groupID >> $AccountInfoFile
         #Write ths GUID information to the case configuration file
         echo $(__ "%s: %s UID %s assigned to %s, configuration file updated." "$(date +%X)" "$remoteAddress" "$groupID" "$caseid") >> $SYSTEMLOGFILE
         echo $(__ "%s: %s GUID %s assigned to %s, configuration file updated." "$(date +%X)" "$remoteAddress" "$groupID" "$caseid") >> $SYSTEMLOGFILE
         echo "Section:Case-UID-Begin" >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo $caseid",case,usr"$caseid","$userID",grp"$caseid","$groupID >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "Section:Case-UID-END" >> $FIRESTOR"/"$caseid"/conf/case.conf"
         echo "" >> $FIRESTOR"/"$caseid"/conf/case.conf"        
         echo "Section:Case-Modules-Begin" >> $FIRESTOR"/"$caseid"/conf/case.conf" 
         echo "Section:Case-Modules-END" >> $FIRESTOR"/"$caseid"/conf/case.conf" 
         return_message "CASE_CREATED"
    ;;
    "addmodule")
        if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi 
        if ! modulefilename="$(getNamedValue $queryString "modulefilename")"; then return_message "CHECK_INPUT"; fi
        if ! workDirName="$(getNamedValue $queryString "workdirname")"; then return_message "CHECK_INPUT"; fi
        
        if [ -f $modulefilename ]; then
          uidSectionBegin="Section:Case-UID-Begin";
          uidSectionEnd="Section:Case-UID-END";
          modSectionBegin="Section:Case-Modules-Begin";
          modSectionEnd="Section:Case-Modules-END";
          caseConfigFile=$FIRESTOR"/"$caseid"/conf/case.conf"
          newModuleInfo="";
 
          userID=$(allocateID "UID");
          httpPrt=$(allocateID "HTTPP");
          #All good, updating configuration and write this information to the assigned numbers file
          modifyConfig "UID_LASTASSIGNED" $userID $SYSTEMCONFIGFILE;
          modifyConfig "HTTPPORT_LASTASSIGNED" $userID $SYSTEMCONFIGFILE;
          #Get existing user and groupinfo and add the new information
          currentAccountInfo=$(readFileSection $caseConfigFile $uidSectionBegin $uidSectionEnd);
          #Get existing module and httpportinfo and add the new information
          currentModuleInfo=$(readFileSection $caseConfigFile $modSectionBegin $modSectionEnd);  
          
          OFS=$IFS;
          IFS=$(echo "\n\b");
          #Finding the case groupname
          for account in $currentAccountInfo
          do
             type=$(echo $account | cut -d ',' -f 2);
             if [ "$type" = "case" ]; then
                groupID=$(echo $account | cut -d ',' -f 6);
             fi
          done
          IFS=$OFS;
                       
          accountInfo=$caseid",module,usr"$userID","$userID",grp"$caseid","$groupID;
          echo $accountInfo >> $AccountInfoFile;
          moduleInfo="$caseid,usr$userID,$modulefilename,$httpPrt,$workDirName";
          echo $moduleInfo >> $ModulesInfoFile;
 
          newAccountInfo="$currentAccountInfo\n$accountInfo";
          echo "Writing account information\n$newAccountInfo" >> $SYSTEMLOGFILE
          changeFileSection $caseConfigFile $uidSectionBegin $uidSectionEnd "$newAccountInfo";

          if [ ${#newModuleInfo} = "" ]; then
             newModuleInfo="$moduleInfo";
          else
             newModuleInfo="$currentModuleInfo\n$moduleInfo";
          fi
          echo "Writing module information\n$newModuleInfo" >> $SYSTEMLOGFILE;
          changeFileSection $caseConfigFile $modSectionBegin $modSectionEnd "$newModuleInfo";
          echo "Module linked" >> $SYSTEMLOGFILE
          return_message "READY";
        else
          return_message "MODULE_NOT_FOUND"
        fi
    ;;
    "caseexist") 
        #Get the required variables from the QUERY_STRING
        if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
        checkcaseexist $caseid;
        return_message "CASE_NOTEXISTS";
    ;;
    "getmodules")
        if ! modlocation="$(getNamedValue $queryString "modlocation")"; then return_message "CHECK_INPUT"; fi
        case $modlocation in
          "USB")
             getModuleDefinitions "USB";              
          ;;
          "INTERNAL")
             getModuleDefinitions "INTERNAL";
          ;;
        esac
    ;;
    "getlinkedmodules")
        if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
        caseLinkedModulesJSON $caseid;
    ;;
    "getcases")
        casesToJSON;
    ;;
    "opencase")
        if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
        caseMaster "open" $caseid
    ;;
    "closecase")
        #if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
        caseMaster "close" #$caseid
    ;;
    "closereopen")
        #if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
        caseMaster "closereopen" #$caseid
    ;;
    "reopencase")
       caseMaster "reopen";
    ;;
    "shutdown")
        #if ! caseid="$(getNamedValue $queryString "caseid")"; then return_message "CHECK_INPUT"; fi
        caseMaster "close" $caseid
        echo "SHUTDOWN_RECEIVED";
        lcd c
        lcd g 0 0 
        lcd p "Shutting down"
        if [ -f "$FBSTATUSLOCATION/OPENEDCASE" ]; then
          echo $(__ "%s: %s removing OPENEDCASE file" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE 
          rm -f "$FBSTATUSLOCATION/OPENEDCASE"; 
        fi
        if [ -f "$FBSTATUSLOCATION/FBSTARTED" ]; then 
          rm -f "$FBSTATUSLOCATION/FBSTARTED"; 
          echo $(__ "%s: %s removing FBSTARTED file" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE
        fi
        lcd g 0 1
        lcd p "Unmounting FIRESTOR"
        umount -f $FIRESTOR
        lcd g 0 2
        lcd p "Stopping RAID"
        mdadm --stop "/dev/md0";
        lcd g 0 3
        lcd p "Ready, poweroff"
        poweroff
        #halt;
    ;;
    "mountmoduledisk")
       prepareAndMountModDisk
    ;;
    "getcasemenu")
        directory=$FIRESTOR"/.firebrick/status"
        if [ -f $directory"/OPENCASE" ]; then
            caseid=$(cat $directory"/OPENCASE");
            echo $(__ "%s: %s Read OPENCASE file and found caseID %s creating menu now." "$(date +%X)" "$remoteAddress" "$caseid") >> $SYSTEMLOGFILE;
            menu=$(createCaseMenuJSON $caseid);
            echo $menu;           
        else
           return_message "NO_OPENED_CASE";
        fi
    
    ;;
    "getdatetime")
        date=$(date +%d-%m-%Y); #$(date +%x);
        time=$(date +%X);
        echo $(__ "%s: %s the client retrieved FIREBrick date and time the following %s %s was sent." "$(date +%X)" "$remoteAddress" "$date" "$time") >> $SYSTEMLOGFILE;
        datetime='{"datetime":[{"day": "'$(echo $date | cut -d "-" -f 1)'", "month": "'$(echo $date | cut -d "-" -f 2)'", "year": "'$(echo $date | cut -d "-" -f 3)'", "hour": "'$(echo $time | cut -d ":" -f 1)'", "minute": "'$(echo $time | cut -d ":" -f 2)'", "second": "'$(echo $time | cut -d ":" -f 3)'"}]}';     
        echo $datetime;            
    ;;
    "setdatetime")
       if ! clientdatetime="$(getNamedValue $queryString "clienttime")"; then return_message "CHECK_INPUT"; fi    
       echo $(__ "%s: %s the time of the FIREBrick wil be updated to %s" "$(date +%X)" "$remoteAddress" "$clientdatetime") >> $SYSTEMLOGFILE;
       date=$(echo $clientdatetime | cut -d ' ' -f 1);
       time=$(echo $clientdatetime | cut -d ' ' -f 2);

       if [ $devel -eq 1 ]; then       
          datestr=$(echo $date | cut -d '-' -f 1)" "$(echo $date | cut -d '-' -f 2)" "$(echo $date | cut -d '-' -f 3)" "$time;
       else
          case $(echo $date | cut -d '-' -f 2) in
            "January")
               month="01"
            ;;
            "February")
               month="02"
            ;;
            "March")
               month="03"
            ;;
            "April")
               month="04"
            ;;
            "May")
               month="05"
            ;;
            "June")
               month="06"
            ;;
            "July")
               month="07"
            ;;
            "August")
               month="08"
            ;;
            "September")
               month="09"
            ;;
            "October")
               month="10"
            ;;
            "November")
               month="11"
            ;;
            "December")
               month="12"
            ;;
          esac
          datestr=$(echo $date | cut -d '-' -f 3)$month$(echo $date | cut -d '-' -f 1)$(echo $time | cut -d ':' -f 1)$(echo $time | cut -d ':' -f 2)
       fi

       result=$(date --set="$datestr" 2>&1);
       status=$?;
       if [ $status -eq 0 ]; then
          echo $(__ "%s: %s the date and time has been sucessfully updated on the FIREBrick %s" "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
          return_message "DATETIME_UPDATED";
       else
          echo $(__ "%s: %s error setting date and time! Error: %s" "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
          return_message "ERROR_SETTING_DATETIME";
       fi
    ;;
    "setdtcancel")
       if ! clientdatetime="$(getNamedValue $queryString "clienttime")"; then return_message "CHECK_INPUT"; fi    
       echo $(__ "%s: %s client canceled the set date time dialog which was displayed to inform the date and time are of by more than 5 minutes between FIREBrick and Client, the client time is %s" "$(date +%X)" "$remoteAddress" "$clientdatetime") >> $SYSTEMLOGFILE;    
    ;;
    "getstorageinfo")
       storageInfoToJSON;
    ;;
    "initstorage")
       initStorage;
    ;;
    "reopenstate")
       caseMaster "reopenstate";
    ;;
    "cancelreopen")
       caseMaster "cancelreopen"; 
    ;;
    "iscaseopen")
       caseMaster "iscaseopen";
    ;;
  esac
fi
