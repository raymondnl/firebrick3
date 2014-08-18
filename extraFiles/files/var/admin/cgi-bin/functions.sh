#!/bin/dash
# This file contains functions called by the FIREBrick CGI/Script-files

__ () {
  # Title            : __
  # Function         : Translates text
  # Input            : Message and variables
  # Output           : Translates text with the variables
  # Last modified by : Raymond van den Heuvel
  # Depends on	     : The variables LANGUAGE (eg. nl_NL), TEXTDOMAIN (eg. scriptname.sh), TEXTDOMAINDIR (eg. /firebrick/locale)
  # Usage	     : echo "$(__ "TEXT")", or echo "$(__ "TEXT %s" "variable")"
  # Modification date: 
  # Origin           : http://docs.unity-inux.org/I18n_Support_and_Shell_Scripts
  
      #if [ ${#LANGUAGE} -eq 0 ] && [ ${#TEXTDOMAIN} -eq 0 ] && [ ${#TEXTDOMAINDIR} -eq 0 ]; then
      #	return_message "LOCALIZATION_ERROR";
      #fi

      gettextopts="-d $TEXTDOMAIN -e --"
      TEXT=$1
      #TEXT=`gettext $gettextopts "$1"`
      #[ "$(echo $1|grep "\\\n$")" ] && TEXT="$TEXT\n"
      #[ "$1" = *$'\n' ] && TEXT="$TEXT\n"
      #if [ "$TEXT" = "$1" ]; then
      #	#Translation Failed, revert to en_GB
      #	LANGUAGE="en_GB"
      #  gettextopts="-d $TEXTDOMAIN -e --"
      #  TEXT=`gettext $gettextopts "$1"`
      #  [ "$(echo $1|grep "\\\n$")" ] && TEXT="$TEXT\n"
      #  [ "$1" = *$'\n' ] && TEXT="$TEXT\n"    	
      #fi
      
      shift
      printf -- "$TEXT" "$@"
}

readConfigFile() {
  # Title            : readConfigFile
  # Function         : Reads configuration file
  # Input            : configuration filename
  # Output           : -
  # Last modified by : Raymond van den Heuvel
  # Modification date: 

	configFile=$1;
	if [ ${#logFile} -ne 0 ]; then
		if [ -f $configFile ]; then
		   echo $(__ "%s: %s found, include file!" "$(date +%X)" "$configFile") >> $SYSTEMLOGFILE
		   source $SYSTEMCONFIGFILE;
		else
		   echo $(__ "%s: %s not found, using default values!" "$(date +%X)" "$configFile") >> $SYSTEMLOGFILE
		fi
	fi
}

return_message() {
  # Title            : return_message
  # Function         : Returns message to be display or interpreted by Javascript-Clientside
  # Input            : Message
  # Output           : 
  # Last modified by : Raymond van den Heuvel
  # Modification date: 

  message=$1
  if [ ${#message} -ne 0 ]; then
    echo $message;
    exit;
  else
    echo "NO_MSG_TO_RETURN";
    exit;
  fi
}

isMounted() {
  # Title            : isMounted
  # Function         : Checks if the mountpoint is mounted
  # Input            : mountpoint
  # Output           : -
  # Last modified by : Raymond van den Heuvel
  # Modification date: 


	mountPoint=$1;
	if [ ${#mountPoint} -ne 0 ]; then
	    if mount | grep $mountPoint > /dev/null ; then
    		return 0;
    	    else
    		return 1;
    	    fi
	else
		return_message "CHECK_INPUT";
		exit;
	fi
}

logDirectoryExist() {
  # Title            : logDirectoryExist
  # Function         : Check if the logs folder exists
  # Input            : -
  # Output           : On failure NO_LOG_DIRECTORY
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  
  	if ! isMounted $FIRESTOR; then
		return_message "FIRESTOR_NOT_MOUNTED";
		exit;
  	fi  
  
  	if [ -w $FIRESTOR ]; then
		if [ ! -d $FBLOGBASE"/"$TODAYFOLDER ]; then
			mkdir -p $FBLOGBASE"/"$TODAYFOLDER
			if [ ! -d $FBLOGBASE"/"$TODAYFOLDER ]; then
				return_message "NO_LOG_DIRECTORY";
				exit;
			fi
		fi
		if [ ! -w $FBLOGBASE"/"$TODAYFOLDER ]; then
			return_message "NO_WRITE_ACCESS";
		fi
	else
		return_message "NO_WRITE_ACCESS";
	fi
}

createDefaultConfigFile(){
  # Title            : createDefaultConfigFile
  # Function         : Creates confiruation file with default values
  # Input            : -
  # Output           : -
  # Last modified by : Raymond van den Heuvel
  # Modification date: 

	echo "#System-settings" > $SYSTEMCONFIGFILE;
	echo "devel=0" >> $SYSTEMCONFIGFILE;
        echo "runningvirtual=0" >> $SYSTEMCONFIGFILE;
	echo "" >> $SYSTEMCONFIGFILE;
	echo "#Language-Settings" >> $SYSTEMCONFIGFILE;
	echo "LANGUAGE=en_GB" >> $SYSTEMCONFIGFILE;
	echo "" >> $SYSTEMCONFIGFILE;
	echo "#File-Locations" >> $SYSTEMCONFIGFILE;
	echo "FIRESTOR=/firestor" >> $SYSTEMCONFIGFILE;
	echo "FBLOGBASE=/firestor/.firebrick/logs" >> $SYSTEMCONFIGFILE;
	echo "FBMODULELOCATION=/firestor/.firebrick/modules" >> $SYSTEMCONFIGFILE;
        echo "FBSTATUSLOCATION=/firestor/.firebrick/status" >> $SYSTEMCONFIGFILE;
	echo "TEXTDOMAINDIR=/fblocale" >> $SYSTEMCONFIGFILE;
	echo "AccountInfoFile=/firestor/.firebrick/config/assigned_UIDs-GIDs.csv" >> $SYSTEMCONFIGFILE;
	echo "ModulesInfoFile=/firestor/.firebrick/config/assigned_Modules.csv" >> $SYSTEMCONFIGFILE;
	echo "URLENCODE=/var/admin/cgi-bin/urlencode.sed" >> $SYSTEMCONFIGFILE;
	echo "URLDECODE=/var/admin/cgi-bin/urldecode.sed" >> $SYSTEMCONFIGFILE;
	echo "" >> $SYSTEMCONFIGFILE;
	echo "#Mod-Disk variables" >> $SYSTEMCONFIGFILE;
	echo "USBMODSLEEPSTEP=1" >> $SYSTEMCONFIGFILE;
	echo "USBMODMAXWAIT=10" >> $SYSTEMCONFIGFILE;
	echo "USBMODSYSDIRECTORY=/sys/block" >> $SYSTEMCONFIGFILE;
	echo "USBMODFINDDEV=sd[a-d]" >> $SYSTEMCONFIGFILE;
	echo "USBMODMODULELOCATION=/mnt/modules" >> $SYSTEMCONFIGFILE;
	echo "" >> $SYSTEMCONFIGFILE;
	echo "#Group-,User-ID and HTTP-Port values MIN/MAX/Assigned" >> $SYSTEMCONFIGFILE;
	echo "GID_MAX=65536" >> $SYSTEMCONFIGFILE;
	echo "GID_MIN=55537" >> $SYSTEMCONFIGFILE;
	echo "GID_LASTASSIGNED=65536" >> $SYSTEMCONFIGFILE;
	echo "UID_MAX=55536" >> $SYSTEMCONFIGFILE;
	echo "UID_MIN=45537" >> $SYSTEMCONFIGFILE;
	echo "UID_LASTASSIGNED=55536" >> $SYSTEMCONFIGFILE;
	echo "HTTPPORT_MAX=64000" >> $SYSTEMCONFIGFILE;
	echo "HTTPPORT_MIN=63000" >> $SYSTEMCONFIGFILE;
	echo "HTTPPORT_LASTASSIGNED=64000" >> $SYSTEMCONFIGFILE;
}

systemConfigFileExist() {
  # Title            : systemConfigFileExist
  # Function         : Check if a system config file exists
  # Input            : -
  # Output           : On failure NO_LOG_DIRECTORY
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  
    # Check if firestor is mounted
  	if ! isMounted $FIRESTOR; then
		return_message "FIRESTOR_NOT_MOUNTED";
		exit;
  	fi
  	
  	# Check if we can wrtie fo firestor
  	if [ -w $FIRESTOR ]; then
  		#check if a config folder exists
		if [ ! -d $SYSTEMCONFIGFOLDER ]; then
			#If not then create
			mkdir -p $SYSTEMCONFIGFOLDER
			if [ ! -d $SYSTEMCONFIGFOLDER ]; then
				return_message "NO_SYSTEM_DIRECTORY";
				exit;
			fi
		fi
		#Check if config file exists
		if [ ! -f $SYSTEMCONFIGFILE ]; then
		   #If not write log and create a new config file with default values
		   echo $(__ "%s: %s file %s does not exist, creating a new one" "$(date +%X)" "$remoteAddress" "$SYSTEMCONFIGFILE") >> $SYSTEMLOGFILE
		   touch $SYSTEMCONFIGFILE;
		   if [ ! -f $SYSTEMCONFIGFILE ]; then
		      echo $(__ "%s: %s file %s could not be created!" "$(date +%X)" "$remoteAddress" "$SYSTEMCONFIGFILE") >> $SYSTEMLOGFILE
		      return_message "NO_SYSTEM_CONFIGFILE";
		      exit;		
		   fi
		   createDefaultConfigFile
		fi	
	else
		return_message "NO_WRITE_ACCESS";
	fi
  

}

minValueColumn() {
  # Title            : minvalueColumn
  # Function         : Check lowest value in column
  # Input            : Column, File
  # Output           : int
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  # Origin	     : http://www.unixcl.com/2008/10/find-min-max-of-column-using-awk-bash.html
 
  colNum=$1;
  fileName=$2;

  if [ ${#colNum} -gt 0 ] && [ ${#fileName} -gt 0 ] && [ -f $fileName ]; then
  	output=$(awk 'min=="" || $x < min {min=$'$colNum'} END{ print min}' FS="," $fileName);
  fi
  
  echo $output;
}
  
maxValueColumn() {
  # Title            : maxValueColumn
  # Function         : Check heighest value in column
  # Input            : Column, File
  # Output           : int
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  # Origin	     : http://www.unixcl.com/2008/10/find-min-max-of-column-using-awk-bash.html
 
  colNum=$1;
  fileName=$2;

  if [ ${#colNum} -gt 0 ] && [ ${#fileName} -gt 0 ] && [ -f $fileName ]; then
  	output=$(awk 'max=="" || $x > max {max=$'$colNum'} END{ print max}' FS="," $fileName);
  fi
  
  echo $output;
}

equalValueColumn() {
  # Title            : maxValueColumn
  # Function         : Check is value matches value in column and return value from column
  # Input            : value, Column, returnColnum, File
  # Output           : 
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  # Origin	     : http://www.unixcl.com/2008/10/find-min-max-of-column-using-awk-bash.html
  
  value=$1
  colNum=$2;
  returnColnum=$3;
  fileName=$4;

  if [ ${#value} -gt 0 ] && [ ${#returnColnum} -gt 0 ] && [ ${#colNum} -gt 0 ] && [ ${#fileName} -gt 0 ] && [ -f $fileName ]; then
	output=$(awk '$'$colNum' == '$value' { print $'$returnColnum'}' FS="," $fileName)
  fi

  echo $output;
}

modifyConfig() {
  # Title            : modifyConfig
  # Function         : Modifies configuration file
  # Input            : Target keyname, Value/Replacement value, Configurationfile name
  # Output           : -
  # Last modified by : Raymond van den Heuvel
  # Modification date: 

	TARGET_KEY=$1
	REPLACEMENT_VALUE=$2
	CONFIG_FILE=$3
	
	if [ ${#TARGET_KEY} -ne 0 ] && [ ${#REPLACEMENT_VALUE} -ne 0 ] && [ ${#CONFIG_FILE} -ne 0 ]; then
		if [ -f $CONFIG_FILE ]; then
			if ! `sed -i "s/\($TARGET_KEY *= *\).*/\1$REPLACEMENT_VALUE/" $CONFIG_FILE`;then
				return_message "ERROR_UPDATING_CONFIGURATION";
			fi
		else
			return_message "CFG_NOT_EXIST";
		fi
	else
		return_message "CHECK_INPUT";
	fi
}

getConfigItem() {
  # Title            : getConfigItem
  # Function         : Gets the value of a configuration key
  # Input            : COnfiguration key, Configurationfile
  # Output           : The value, or error
  # Last modified by : Raymond van den Heuvel
  # Modification date: 


	TARGET_KEY=$1
	CONFIG_FILE=$2
	
	if [ ${#TARGET_KEY} -ne 0 ] && [ ${#CONFIG_FILE} -ne 0 ]; then
		if [ -f $CONFIG_FILE ]; then
			value=`sed -n -e "/$TARGET_KEY=/ s/.*\= *//p" $CONFIG_FILE`
			if [ ${#value} -eq 0 ]; then
				echo "CFG_KEY_NOT_EXIST"
			else
				echo $value;
			fi
		else
			return_message "CFG_NOT_EXIST";
		fi
	else
		return_message "CHECK_INPUT";
	fi
}

checkcaseexist() {
  # Title            : checkcaseexist
  # Function         : Check if the case folder already exists
  # Input            : Casenumber
  # Output           : CASE_EXISTS or CASE_NOTEXIST
  # Last modified by : Raymond van den Heuvel
  # Modification date: 
  casenumber=$1;
  
  if [ ${#casenumber} -eq 0 ]; then
    return_message "NO_CASENR_RECEIVED";
  else
    if [ -d $FIRESTOR"/"$casenumber ]; then
     echo $(__ "%s: %s case %s exists!" "$(date +%X)" "$remoteAddress" "$casenumber") >> $SYSTEMLOGFILE;
     return_message "CASE_EXISTS";
     exit;
    else
      echo $(__ "%s: %s case %s does not exist" "$(date +%X)" "$remoteAddress" "$casenumber") >> $SYSTEMLOGFILE;
    fi
  fi
}

parseAndFillVariables() {
  # Title            : parseAndFillVariables
  # Function         : Check the env variables and put them in a variable
  # Input            : -
  # Output           : filled variables
  # Last modified by : Raymond van den Heuvel
  # Modification date:

	#QUERY_STRING="name=Raymond&likeProduct=yes&comments=Goed&sub=Submit"
	envVar=`env`;
	#echo "<br>---------------<br>";
	#echo $envVar;
	#echo "<br>---------------<br>";
	if [ ${#envVar} -ne 0 ]; then
	  for varPair in $envVar; do
	       varName=$(echo $varPair | cut -d "=" -f 1)
	       case $varName in
	          "CONTENT_LENGTH") contentLength=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#contentLength} -eq 0 ]; then return_message "NO_VAR_contentLenght"; fi
	          ;;
	          "CONTENT_TYPE") contentType=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#contentType} -eq 0 ]; then return_message "NO_VAR_contentType"; fi
	          ;;
	          "HTTP_HOST") httpHost=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#httpHost} -eq 0 ]; then return_message "NO_VAR_httpHost"; fi
	          ;;
	          "HTTP_REFERER") httpReferer=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#httpReferer} -eq 0 ]; then return_message "NO_VAR_httpReferrer"; fi
	          ;;
	          "HTTP_USER_AGENT") httpUserAgent=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#httpUserAgent} -eq 0 ]; then return_message "NO_VAR_httpUserAgent"; fi
	          ;;
	          "REMOTE_ADDR") remoteAddress=$(echo $varPair | cut -d "=" -f 2)
	          		            if [ ${#remoteAddress} -eq 0 ]; then return_message "NO_VAR_remoteAddress"; fi
	          ;;
	          "REQUEST_METHOD") requestMethod=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#requestMethod} -eq 0 ]; then return_message "NO_VAR_requestMethod"; fi
	          ;;
	          "REQUEST_URI") requestUri=$(echo $varPair | cut -d "=" -f 2)
	                            if [ ${#requestUri} -eq 0 ]; then return_message "NO_VAR_requestUri"; fi
	          ;;
	          "SCRIPT_FILENAME") scriptFileName=$(echo $varPair | cut -d "=" -f 2)  
	                            if [ ${#scriptFileName} -eq 0 ]; then return_message "NO_VAR_scriptFileName"; fi
	          ;;
	          "PATH") scriptPath=$(echo $varPair | cut -d "=" -f 2)  
	                            if [ ${#scriptPath} -eq 0 ]; then return_message "NO_VAR_varPair"; fi
	          ;;
	       esac
	  done

	  # Reading QUERY_STRING seems to be somewhat different, that we'll do here	  
	  read QUERY_STRING
	  queryString=$QUERY_STRING
	  if [ ${#queryString} -eq 0 ]; then 
	    return_message "NO_VAR_QUERYSTRING"; 
	  fi
	fi
}

getNamedValue(){
  # Title            : getNamedValue
  # Function         : Returns the value of specified name
  # Input            : String to look in, String to look for
  # Output           : Bool 1, value
  # Last modified by : Raymond van den Heuvel
  # Modification date:

	fullString=$(urlDecode $1)
	searchString=$2
	
	if [ ${#searchString} -ne 0 -a ${#fullString} -ne 0 ]; then
	
	   value=$(echo $fullString | sed -n 's/^.*'$searchString'=\([^&]*\).*$/\1/p');
    	   if [ "$value" = "$fullString" ] ||  [ ${#value} -eq 0 ]; then 
      	      echo $(__ "%s: %s searched for %s in %s, but the value could not be found!" "$(date +%X)" "$remoteAddress" "$searchString" "$fullString") >> $SYSTEMLOGFILE
      	      return 1; 
    	   else
     	      echo $(__ "%s: %s searched for %s in %s, and found value %s" "$(date +%X)" "$remoteAddress" "$searchString" "$fullString" "$value") >> $SYSTEMLOGFILE;
      	      echo $value;
    	   fi
	else
		return_message "CHECK_INPUT";
		exit;
	fi


}

isSubString() {
  # Title            : isSubString
  # Function         : Checks whether one string is part the other string
  # Input            : String to look for, String to look in
  # Output           : Bool 0, 1 or CHECK_INPUT
  # Last modified by : Raymond van den Heuvel
  # Modification date:

	subString=$1;
	fullString=$2;
	if [ ${#subString} -ne 0 -a ${#fullString} -ne 0 ]; then
		for s in $fullString; do
			if case ${s} in *"${subString}"*) true;; *) false;; esac; then
				return 0;
			else
				return 1;
			fi
		done
	else
		return_message "CHECK_INPUT";
		exit;
	fi
}

allocateID(){
	# Title            : allocateID
	# Function         : Allocates an ID based on configuration data an historic data
	# Input            : "UID"/"GUID"/"HTTPP"
	# Output           : An unallocated number, CHECK_INPUT
 	# Last modified by : Raymond van den Heuvel
 	# Modification date:

	# File columns layout: CasedID,Type,UserName,UID,GroupName,GID
	# Setting variables for column numbers
	typeOfID=$1;

	if [ $typeOfID = "UID" ]; then
		#Finding a unused UID for this case
		ASS_CASEID_COL=1
   		ASS_GUID_COL=6
   		ASS_UID_COL=4
        userID=$(($(getConfigItem "UID_LASTASSIGNED" $SYSTEMCONFIGFILE)-1));
        if [ $userID -ge $(getConfigItem "UID_MIN" $SYSTEMCONFIGFILE) ]; then
            #Based on configuration file I found a free UID, let's check our UID history
            equal=$(equalValueColumn $userID $ASS_UID_COL $ASS_CASEID_COL $AccountInfoFile);
            if [ ${#equal} -gt 0 ]; then
                #Hmmm it seems this UID was already used... counting from storage initialisation
                echo $(__ "%s: %s UID %s is already assigned to %s, looking for another UID!" "$(date +%X)" "$remoteAddress" "$userID" "$equal") >> $SYSTEMLOGFILE
                equal="";
                #generating a new UID, based on lowest UID in the assigned number file - 1 :-)
                userID=$(($(minValueColumn $ASS_UID_COL $AccountInfoFile)-1));
                # Final check if the GUID is available
                if [ $userID -ge $(getConfigItem "UID_MIN" $SYSTEMCONFIGFILE) ]; then                   
                   equal=$(equalValueColumn $userID $ASS_UID_COL $ASS_CASEID_COL $AccountInfoFile);
                   if [ ${#equal} -gt 0 ]; then
                       return_message "ERROR_NO_UNUSED_UID"                     
                   fi
                else
                   return_message "ERROR_ALLOCATING_UID"
                fi                 
            fi
		fi
		echo $userID;
	elif [ $typeOfID = "GUID" ]; then
		#Finding a unused GUID for this case
        ASS_CASEID_COL=1
   		ASS_GUID_COL=6
   		ASS_UID_COL=4
        groupID=$(($(getConfigItem "GID_LASTASSIGNED" $SYSTEMCONFIGFILE)-1));
        if [ $groupID -ge $(getConfigItem "GID_MIN" $SYSTEMCONFIGFILE) ]; then
            #Based on configuration file I found a free GUID, let's check our GUID history
            equal=$(equalValueColumn $groupID $ASS_GUID_COL $ASS_CASEID_COL $AccountInfoFile);
            if [ ${#equal} -gt 0 ]; then
                #Hmmm it seems this GUID was already used... counting from storage initialisation
                echo $(__ "%s: %s GUID %s is already assigned to %s, looking for another GUID!" "$(date +%X)" "$remoteAddress" "$groupID" "$equal") >> $SYSTEMLOGFILE
                equal="";
                #generating a new GUID, based on lowest GUID in the assigned number file - 1 :-)
                groupID=$(($(minValueColumn $ASS_GUID_COL $AccountInfoFile)-1));
                # Final check if the GUID is available
                if [ $groupID -ge $(getConfigItem "GID_MIN" $SYSTEMCONFIGFILE) ]; then                   
                   equal=$(equalValueColumn $groupID $ASS_GUID_COL $ASS_CASEID_COL $AccountInfoFile);
                   if [ ${#equal} -gt 0 ]; then
                       return_message "ERROR_NO_UNUSED_GID"                     
                   fi
                else
                   return_message "ERROR_ALLOCATING_GID"
                fi                 
            fi
		fi
		echo $groupID;
	elif [ $typeOfID = "HTTPP" ]; then
	    #Finding a free HTTP port
	    ASS_CASEID_COL=1
   	    ASS_HTTPP_COL=4
	    httpPort=$(($(getConfigItem "HTTPPORT_LASTASSIGNED" $SYSTEMCONFIGFILE)-1));
	    if [ $httpPort -ge $(getConfigItem "HTTPPORT_MIN" $SYSTEMCONFIGFILE) ]; then
	       equal=$(equalValueColumn $httpPort $ASS_HTTPP_COL $ASS_CASEID_COL $ModulesInfoFile);
           if [ ${#equal} -gt 0 ]; then
                #Hmmm it seems this HTTP-Port was already used... counting from storage initialisation
                echo $(__ "%s: %s HTTP-Port %s is already assigned to %s, looking for another PORT!" "$(date +%X)" "$remoteAddress" "$httpPort" "$equal") >> $SYSTEMLOGFILE
                equal="";
                #generating a new PORT, based on lowest PORT in the assigned port file - 1 :-)
                httpPort=$(($(minValueColumn $ASS_HTTPP_COL $ModulesInfoFile)-1));
                # Final check if the GUID is available
                if [ $httpPort -ge $(getConfigItem "HTTPPORT_MIN" $SYSTEMCONFIGFILE) ]; then                   
                   equal=$(equalValueColumn $httpPort $ASS_HTTPP_COL $ASS_CASEID_COL $ModulesInfoFile);
                   if [ ${#equal} -gt 0 ]; then
                       return_message "ERROR_NO_UNUSED_HTTPPORT" ;                    
                   fi
                else
                   return_message "ERROR_ALLOCATING_HTTPPORT";
                fi                 
            fi
		fi
		echo $httpPort;
	else
		return_message "CHECK_INPUT";
	fi
}

createAccounts(){
  # Title            : createAccounts
  # Function         : Creates Users and Groups based on the case information
  # Input            : -
  # Output           : returns an error when creation failes
  # Last modified by : Raymond van den Heuvel
  # Modification date: 
	caseid=$1
	
	if [ ${#caseid} -gt 0 ]; then
	    caseConfig=$FIRESTOR"/"$caseid"/conf/case.conf"
	    if [ -f $caseConfig ]; then
	       accounts=$(readFileSection $caseConfig "Section:Case-UID-Begin" "Section:Case-UID-END")
	       if [ ${#accounts} -gt 0 ]; then
	          for account in $accounts
	          do	
	             type=$(echo $account | awk -F "\"*,\"*" '{print $2}');
		     userName=$(echo $account | awk -F "\"*,\"*" '{print $3}');
		     userID=$(echo $account | awk -F "\"*,\"*" '{print $4}');
		     groupName=$(echo $account | awk -F "\"*,\"*" '{print $5}');
		     groupID=$(echo $account | awk -F "\"*,\"*" '{print $6}');
		     if [ ${#type} -gt 0 ] && [ ${#userName} -gt 0 ] && [ ${#userID} -gt 0 ] && [ ${#groupName} -gt 0 ] && [ ${#groupID} -gt 0 ]; then
	                if [ $type = "case" ]; then
		           #echo "addgroup --gid "$groupID" "$groupName" 2>&1"
	                   result=$(addgroup --gid $groupID $groupName 2>&1);
		           status=$?
		           if [ $status -eq 0 ]; then
			      echo $(__ "%s: %s group %s(%s) created" "$(date +%X)" "$remoteAddress" "$groupName" "$groupID") >> $SYSTEMLOGFILE
		           else
		              echo $(__ "%s: %s group %s(%s) not created! Error: %s" "$(date +%X)" "$remoteAddress" "$groupName" "$groupID" "$result") >> $SYSTEMLOGFILE
			      return_message "ERROR_CREATING_GROUP";
		           fi
		        elif [ $type = "module" ]; then
			   #echo "useradd -M -g "$groupName" -u "$userID" "$userName" 2>&1"
			   if [ "$devel" = "1" ]; then
		              result=$(useradd -M -g $groupName -u $userID $userName 2>&1);
			   else
                              result=$(adduser --no-create-home --disabled-password -g $groupName -u $userID $userName 2>&1);
			   fi
		 	   status=$?
			   if [ $status -eq 0 ]; then
			      echo $(__ "%s: %s user %s(%s) created" "$(date +%X)" "$remoteAddress" "$userName" "$userID") >> $SYSTEMLOGFILE
			   else
			      echo $(__ "%s: %s user %s(%s) not created! Error: %s" "$(date +%X)" "$remoteAddress" "$userName" "$userID" "$result") >> $SYSTEMLOGFILE
			      exit;
			   fi
		        else
			      return_message "ERROR_CREATING_USER";
		        fi
	             fi
	           done
		else
		   return_message "NO_ACCOUNT_SECTION_FOUND";
		fi
            else
               return_message "CASECONFIG_NOT_FOUND";
	    fi
   else
   	   return_message "CHECK_INPUT";
   fi
}

preFlightCheck() {
  # Title            : preFlightCheck
  # Function         : Checks the things which are important before actual work is done
  # Input            : -
  # Output           : 
  # Last modified by : Raymond van den Heuvel
  # Modification date: REFERER_NOT_SET, REFERER_NO_MATCH

 	if isMounted $FIRESTOR ; then
 		#Firestor is mounted
		logDirectoryExist;
		#Logdirectory exists
		systemConfigFileExist;

		echo $(__ "%s: %s mounted and log directory available." "$(date +%X)" "$FIRESTOR") >> $SYSTEMLOGFILE

		#Retrieve Variables received from webserver
		#parseAndFillVariables
	
		# Check if the host:port is the same as in the referer uri 
		if [ ${#httpReferer} -ne 0 ]; then
			if ! isSubString $httpHost $httpReferer; then
			    echo $(__ "%s: %s made a request for %s but %s does not match %s!" "$(date +%X)" "$remoteAddress" "$requestUri" "$httpReferer" "$httpHost") >> $SYSTEMLOGFILE
				return_message "REFERER_NO_MATCH";
				exit;
			fi
		else
			#Referer not set, somebody called us directly
			echo $(__ "%s: %s called %s directly!" "$(date +%X)" "$remoteAddress" "$requestUri") >> $SYSTEMLOGFILE
			return_message "REFERER_NOT_SET";
			exit;
		fi
	
		# Check if we were called with POST data, any other means exit
		if [ $requestMethod != "POST" ]; then
		  return_message "NOT_POST_BUT_"$requestMethod;
		  exit;
		fi

	else
		return_message "FIRESTOR_NOT_MOUNTED";
	fi

}

mountDisk() {
  # Title            : mountDisk
  # Function         : Mount a partition to a mountpoint, if the mounpoint does not exist it wil be created
  # Input            : partition (eg. /dev/sdb1), mountpoint (eg. /mnt/disk) 
  # Output           : onerror ERROR_MOUNTING_PARTITION or ERROR_CREATING_MOUNTPOINT
  # Last modified by : Raymond van den Heuvel
  # Modification date:
   partition=$1;
   mountpoint=$2;
   option=$3;

   if [ ${#partition} -gt 0 ] && [ ${#mountpoint} -gt 0 ]; then
      if [ ! -d $mountpoint ]; then
         # Mountpoint does not exist
         echo $(__ "%s: %s mountpoint %s does not exist trying to create now" "$(date +%X)" "$remoteAddress" "$mountpoint") >> $SYSTEMLOGFILE;
	 if [ $devel -eq 1 ]; then
	    mntPnt=$(sudo mkdir $mountpoint 2>&1);
	 else
	    mntPnt=$(mkdir $mountpoint 2>&1);
	 fi
	 status=$?;
	 if [ $status -eq 0 ]; then
	    echo $(__ "%s: %s mountpoint %s created" "$(date +%X)" "$remoteAddress" "$mountpoint") >> $SYSTEMLOGFILE;
            #mountpoint created
	    if [ $devel -eq 1 ]; then
	       if [ "$option" = "loopdev" ]; then
		  mnt=$(sudo mount $partition $mountpoint -o ro 2>&1);
	       else
	          mnt=$(sudo mount $partition $mountpoint -o ro,noexec 2>&1);
	       fi
	    else
	       if [ "$option" = "loopdev" ]; then
		  mnt=$(mount $partition $mountpoint -o ro 2>&1);
	       else
	          mnt=$(mount $partition $mountpoint -o ro,noexec 2>&1);
	       fi
	    fi
	    status=$?;
	    if [ $status -ne 0 ]; then
	       #problem mounting the USB Stick
	       echo $(__ "%s: %s error mounting storage %s" "$(date +%X)" "$remoteAddress" "$mnt") >> $SYSTEMLOGFILE
	       return_message "ERROR_MOUNTING_PARTITION";
	    else
	       echo $(__ "%s: %s %s mounted on %s" "$(date +%X)" "$remoteAddress" "$partition" "$mountpoint") >> $SYSTEMLOGFILE
	    fi	    
	 else
	    echo $(__ "%s: %s error creating mountpoint %s" "$(date +%X)" "$remoteAddress" "$mntPnt") >> $SYSTEMLOGFILE
	    return_message "ERROR_CREATING_MOUNTPOINT";
	    exit;
	 fi
      else
	 if [ $devel -eq 1 ]; then
	    if [ "$option" = "loopdev" ]; then
	       mnt=$(sudo mount $partition $mountpoint -o ro 2>&1);
	    else
	       mnt=$(sudo mount $partition $mountpoint -o ro,noexec 2>&1);
	    fi
	 else
	    if [ "$option" = "loopdev" ]; then
	       mnt=$(mount $partition $mountpoint -o ro 2>&1);
	    else
	       mnt=$(mount $partition $mountpoint -o ro,noexec 2>&1);
	    fi
	 fi
	 status=$?;
	 if [ $status -ne 0 ]; then
	    #problem mounting the USB Stick
	    if [ "$option" = "loopdev" ]; then
               echo $(__ "%s: %s error mounting modulefile %s" "$(date +%X)" "$remoteAddress" "$mnt") >> $SYSTEMLOGFILE
	       return_message "ERROR_MOUNTING_MODULE";
	       exit;
	    else
               echo $(__ "%s: %s error mounting USB storage %s" "$(date +%X)" "$remoteAddress" "$mnt") >> $SYSTEMLOGFILE
	       return_message "ERROR_MOUNTING_PARTITION";
	       exit;
	    fi
	 else
	    echo $(__ "%s: %s %s mounted on %s" "$(date +%X)" "$remoteAddress" "$partition" "$mountpoint") >> $SYSTEMLOGFILE
	 fi	    
      fi
   else
	return_message "CHECK_INPUT";
	exit;
   fi
}

verifyAndDecrypt() {
  # Title            : verifyAndDecrypt
  # Function         : verifies the digital signature of the supplied file and returns the decrypted value
  #		       WARNING only to verify and decrypt the definitionfiles for the firebrick modules NOT
  #		       to decrypt (big) files, text output only!!
  # Input            : Definition file
  # Output           : Decrypted value or error
  # Last modified by : Raymond van den Heuvel
  # Modification date:
 
   definitionFile=$1

   if [ ${#definitionFile} -gt 0 ]; then
	if [ -f $definitionFile ]; then
	   verify=$(gpg --verify $definitionFile 2>&1)
	   result=$?
	   if [ "$result" -eq 0 ]; then
	      content=$(gpg --decrypt $definitionFile 2>/dev/null)
	   else
	      echo $(__ "%s: %s error verifying definitionfile %s" "$(date +%X)" "$remoteAddress" "$verify")  >> $SYSTEMLOGFILE
	      echo "VERIFICATION_ERROR";
	      return;
	   fi
	   echo $(__ "%s: %s successfully verified definitionfile" "$(date +%X)" "$remoteAddress" )  >> $SYSTEMLOGFILE
           echo $content;
	else
	   echo $(__ "%s: %s definitionfile %s not found!" "$(date +%X)" "$remoteAddress" "$definitionFile") >> $SYSTEMLOGFILE
	   echo "DEFINITIONFILE_NOT_FOUND";
	   return;
	fi
   else
	   return_message "CHECK_INPUT"
   fi
}

createDevNodes() {
  # Title            : createDevNodes
  # Function         : Creates DeviceNodes for the plugged in block device
  # Input            : Sys directory, Devicename plugged in
  # Output           : 
  # Last modified by : Raymond van den Heuvel
  # Modification date:
 
   directory=$1;
   pluggedin=$2;
   
   echo $(__ "%s: %s devnode %s %s" "$(date +%X)" "$remoteAddress" "$directory" "$pluggedin") >> $SYSTEMLOGFILE
   if [ ${#directory} -gt 0 ] && [ ${#pluggedin} -gt 0 ]; then
      if [ -f "$directory/$pluggedin/dev" ]; then
	devinfo=$(cat "$directory/$pluggedin/dev")
	major=$(echo $devinfo | cut -d ":" -f 1);
	minor=$(echo $devinfo | cut -d ":" -f 2);
	if [ ! -e "/dev/$pluggedin" ]; then 
           result=$(mknod /dev/$pluggedin b $major $minor 2>&1);
	   status=$?
	   if [ $status -eq 0 ] && [ $devel -eq 0 ]; then
	      echo $(__ "%s: %s device node %s created" "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE
	      echo "";
	   elif [ $devel -eq 1 ]; then
	      #echo $(__ "%s: %s device node %s created" "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE
	      echo "";
	   else
	      echo $(__ "%s: %s error creating devicenode %s" "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE
	      return_message "ERROR_CREATING_DEVICENODE";
	      exit;
	   fi
        fi

	for D in "$directory/$pluggedin/$pluggedin*"
	do
	    devFile=$D"/dev";
	    if [ -f $devFile ]; then
	        devName=$(echo $devFile | cut -d "/" -f 5);
	    	devinfo=$(cat $devFile);
		major=$(echo $devinfo | cut -d ":" -f 1);
		minor=$(echo $devinfo | cut -d ":" -f 2);
		
	        if [ ! -e "/dev/$devName" ]; then 
		   result=$( mknod /dev/$devName b $major $minor 2>&1 );
		   status=$?
		   if [ $status -eq 0 ] && [ $devel -eq 0 ]; then
		      echo $(__ "%s: %s device node %s created" "$(date +%X)" "$remoteAddress" "$restult") >> $SYSTEMLOGFILE
		      echo "";
	           elif [ $devel -eq 1 ]; then
		      echo $(__ "%s: %s device node %s created" "$(date +%X)" "$remoteAddress" "$restult") >> $SYSTEMLOGFILE
		      echo "";
		   else
		      echo $(__ "%s: %s error creating devicenode %s" "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE
		      return_message "ERROR_CREATING_DEVICENODE";
		      exit;
	   	   fi
                fi
	    fi
	done

	partDevice="/dev/$devName";
	device="/dev/$pluggedin";

	if [ ${#partDevice} -gt 5 ]; then
	   if [ $devel -eq 1 ]; then
	      partinfo=$(sudo fdisk -l $device | tail -1 | grep FAT32)
	   else
	      partinfo=$(fdisk -l $device | tail -1 | grep FAT32)
	   fi

	   if [ "$partinfo" != "" ]; then 
		echo $(echo $partinfo | awk '{print $1}' | head -1);
	   else
	    echo $(__ "%s: %s USB-storage does not contain a FAT32 file-system!" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE
		return_message "NO_USB_FAT32_PARTITION_DETECTED";
                exit;
	   fi
	fi
      fi
   else
      return_message "CHECK_INPUT";
      exit;
   fi
}

prepareAndMountModDisk() {
  # Title            : prepareAndMountModDisk
  # Function         : Waits for plugging in a USB block device, create device nodes and mount the blockdevice
  # Input            : 
  # Output           : On error: NO_USBDISK_PLUGGEDIN
  # Last modified by : Raymond van den Heuvel
  # Modification date:
 
   counter=0;
   dirstatnow="";
   pluggedin="";
   dirstatold=$(find $USBMODSYSDIRECTORY"/"$USBMODFINDDEV -maxdepth 1 -print);
   
   echo $(__ "%s: %s Waiting for USB-storage to be plugged in!" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE
   while [ $counter -lt $USBMODMAXWAIT ]; do
     sleep $USBMODSLEEPSTEP
     counter=$(($counter+1));
     #echo $(__ "%s: %s Waiting %s %s %s" "$(date +%X)" "$remoteAddress" "$counter" "$USBMODSLEEPSTEP" "$USBMODMAXWAIT") >> $SYSTEMLOGFILE
     dirstatnow=$(find $USBMODSYSDIRECTORY"/"$USBMODFINDDEV -maxdepth 1 -print);
     if [ "$dirstatold" != "$dirstatnow" ]; then
   	 oldcount=$(echo "$dirstatold" | wc -w);
   	 newcount=$(echo "$dirstatnow" | wc -w);
   	 if [ "$newcount" -gt "$oldcount" ]; then
   	   for item in $dirstatnow
   	   do
   	      compcount=0;
   	      for item2 in $dirstatold
   	      do
   	          if [ "$item" = "$item2" ]; then
   		     break;
   		  else
   		     compcount=$(($compcount+1));
    		  if [ "$compcount" -eq "$oldcount" ]; then
   			counter=$USBMODMAXWAIT;
   			pluggedin=$( echo $item | cut -d "/" -f 4 );
	                echo $(__ "%s: %s Found new block device %s" "$(date +%X)" "$remoteAddress" "$pluggedin") >> $SYSTEMLOGFILE
   		        mountDevice=$(createDevNodes $USBMODSYSDIRECTORY $pluggedin);
			echo $(__ "%s: %s Trying to mount %s on %s" "$(date +%X)" "$remoteAddress" "$mountDevice" "$USBMODMODULELOCATION") >> $SYSTEMLOGFILE
   			mountDisk $mountDevice $USBMODMODULELOCATION
   			exit;
   		    fi
   		  fi
   	      done
   	   done
   	fi
      fi
   done
   echo $(__ "%s: %s no USB storage device plugged in!" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
   return_message "NO_USBDISK_PLUGGEDIN";
}

getDefinitionItem() {
  # Title            : getDefinitionItem
  # Function         : Reads a configuration value from a variable with the configuration data from the module definition file
  # Input            : Searchkey, Configuration values
  # Output           : On error: CHECK_INPUT, the value found belonging to the searchkey
  # Last modified by : Raymond van den Heuvel
  # Modification date:

	TARGET_KEY=$1
	DEFCONFIG=$2
	
	if [ ${#TARGET_KEY} -ne 0 ] && [ ${#DEFCONFIG} -ne 0 ]; then
		for str in $DEFCONFIG
		do
		   value=`echo $str | sed -n -e "/$TARGET_KEY=/ s/.*\= *//p"`
		   if [ ${#value} -gt 0 ]; then
			echo $value;
			return
		   fi
		done		
	else
		return_message "CHECK_INPUT";
	fi
}

definitionDataToJSON() {
  # Title            : definitionDataToJSON
  # Function         : Reads the data from the module definition files on the specified location
  # Input            : definition file location
  # Output           : JSON structured information extracted from the definition files
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   files=$1   

   if [ ${#files} -gt 0 ]; then
	   count=0
	   printFooter=0
	   for f in $files 
	   do
		  if [ ${#f} -gt 0 ]; then
			 if [ -f "$f" ]; then
			printFooter=1
				if [ "$count" -eq 0 ]; then
			   echo '{"modules":['
				   echo '   {'
			   count=1;
				else
			   echo '  ,{';
				fi
				file=$f;
				result=$(verifyAndDecrypt $file);
				echo '     "modulename": "'$(getDefinitionItem "modulename" "$result" )'",'
				echo '     "moduleversion": "'$(getDefinitionItem "moduleversion" "$result" )'",'
				echo '     "moduletype": "'$(getDefinitionItem "moduletype" "$result" )'",'
				echo '     "modulefilename": "'$file'"'
				echo '     }'
			 fi
		  fi
	   done

	   if [ $printFooter -eq 1 ]; then
		  echo '  ]'
		  echo '}'
	   else
		  echo $(__ "%s: %s no data available to create JSON datastructure" "$(date +%X)" "$remoteAddress")
	   fi
   else
      return_message "CHECK_INPUT";
   fi
}

readFileSection() {
  # Title            : readFileSection
  # Function         : Reads the data between two section markers in a file
  # Input            : filename, section begin marker, section end marker
  # Output           : The content between the two markers, on error BAD_INPUT_DATA
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   file=$1
   sectionbegin=$2
   sectionend=$3

   if [ -f $file ] && [ ${#sectionbegin} -gt 0 ] && [ ${#sectionend} -gt 0 ]; then
      section=$(cat $file | sed -n "/$sectionbegin/,/$sectionend/p" | head -n-1 | tail -n+2)
   else
	return_message "BAD_INPUT_DATA"
   fi

   echo "$section"
}

changeFileSection() {
  # Title            : changeFileSection
  # Function         : replasec the data between two section markers and outputs to the same file
  # Input            : filename, section begin marker, section end marker, replacement data
  # Output           : Output to filename
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   file=$1
   sectionbegin=$2
   sectionend=$3
   sectionText="$4"

   if [ -f $file ] && [ ${#sectionbegin} -gt 0 ] && [ ${#sectionend} -gt 0 ] && [ ${#sectionText} -gt 0 ]; then
      sectionBegin=$( grep -n "${sectionbegin}" "${file}" | cut -f 1 -d':' )
      sectionEnd=$( grep -n "${sectionend}" "${file}" | cut -f 1 -d':' )
      fileLines=$(wc -l < $file)

      beforeSection=$(sed -n '1,'$sectionBegin'p' $file)
      afterSection=$(sed -n $sectionEnd','$fileLines'p' $file)
 
      echo "$beforeSection" > $file
      echo "$sectionText" >> $file
      echo "$afterSection" >> $file
   fi
}

accountDataToJSON() {
  # Title            : accountDataToJSON
  # Function         : Converts the user and group data to JSON format
  # Input            : The section of the case configuration
  # Output           : JSON structured information
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   count=0
   printFooter=0
   module=0
   for line in $section
   do
      if [ ${#line} -gt 0 ]; then
 	    printFooter=1
             if [ "$count" -eq 0 ]; then
 	       echo '{"case":['
                echo '   {'
 	       count=1;
             fi
             type=$(echo $line | cut -d ',' -f 2)
 	    if [ "$type" = "case" ]; then
                echo '      "caseid": "'$(echo $line | cut -d ',' -f 1)'"'
                echo '     ,"caseusername": "'$(echo $line | cut -d ',' -f 3)'"'
                echo '     ,"caseuid": "'$(echo $line | cut -d ',' -f 4)'"'
                echo '     ,"casegroupname": "'$(echo $line | cut -d ',' -f 5)'"'
                echo '     ,"casegroupid": "'$(echo $line | cut -d ',' -f 6)'"'
 	    elif [ "$type" = "module" ]; then
 		if [ "$module" = 0 ]; then
 		   module=1
                	   echo '     ,"modules":[{"modusername":"'$(echo $line | cut -d ',' -f 3)'"'
 		else
 		   echo '                 ,"moduserid":"'$(echo $line | cut -d ',' -f 4)'"'
 		   echo '                 ,"modgroupname":"'$(echo $line | cut -d ',' -f 5)'"'
 		   echo '                 ,"modgroupid":"'$(echo $line | cut -d ',' -f 6)'"]}'
 		fi
             fi
       fi
   done
   echo '}]}'
}

getIP() {
  # Title            : getIP
  # Function         : Gets the IP address of a given adapter
  # Input            : adapter
  # Output           : ip address
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   iftype=$1
   ip=$(ifconfig | grep -A 1 $iftype | tail -1 | cut -d ':' -f 2 | cut -d ' ' -f 1)
   echo $ip
}

createCaseMenuJSON() {
  # Title            : createCaseMenuJSON
  # Function         : Creates a JSON menu-structure based on case configuration
  # Input            : CaseID
  # Output           : JSON structured information
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   caseNumber=$1;

   if [ ${#caseNumber} -eq 0 ]; then
	return_message "CHECK_INPUT";
   fi

   casefile=$FIRESTOR"/"$caseNumber"/conf/case.conf"

   if [ -f $caseFile ]; then
      fbIP=$(getIP "eth[0-2]");
      sectionbegin="Section:Case-Modules-Begin";
      sectionend="Section:Case-Modules-END";
      caseID=$(getConfigItem "CaseID" $casefile);
      moduleSection=$(readFileSection $casefile $sectionbegin $sectionend);

      if [ ${#moduleSection} -gt 0 ]; then
         first=1;
         OFS=$IFS;
         IFS=$(echo "\n\b");
         echo '{"menu":[';
         echo -n '   {';
         echo '"menuitem": "Case '$caseID'",';
         echo '    "menugroup": "case",';
         echo '    "menutext": "Case '$caseID'",';
         echo '    "submenu":[';

         for module in $moduleSection
         do
            httpPort=$(echo "$module" | cut -d ',' -f 4);
            moduleName=$(echo "$module" | cut -d ',' -f 5 | sed -e 's/^"//'  -e 's/"$//');
            url="http://"$fbIP":"$httpPort;

            if [ $first -eq 1 ]; then
               echo -n '            {';
               first=0;
            else
               echo -n '           ,{';
            fi
            echo '"submenuitem":"'$moduleName'", "submenutext":"'$moduleName'", "url":"'$url'"}';
         done
         IFS=$OFS;
         echo '     ,{"submenuitem":"menu_sub_closecase", "submenutext":"Close case '$caseID'", "url":"javascript:closingCase();"}';

         echo '     ]}';
         echo -n '    ,{';
         echo '"menuitem": "menu_main_reload",';
         echo '      "menugroup": "sysstate",';
         echo '      "menutext": "System",';
         echo '	     "submenu":[{"submenuitem":"menu_sub_shutdownclean", "submenutext":"Shutdown FIREBrick", "url":"javascript:showShutdown();"}';
         echo '		 ,{"submenuitem":"menu_sub_shutdownopen", "submenutext":"Shutdown reopen case", "url":"javascript:showShutdownopen();"}';
         echo '     ]}';
         echo ']}';
      fi
   else
      return_message "CASE_CONFIG_NOT_FOUND";
   fi
}

urlEncode() {
   # Title            : urlEncode
   # Function         : URLEncodes a string for transport
   # Input            : string
   # Output           : Encoded string
   # Last modified by : Raymond van den Heuvel
   # Modification date:
   # Origin           : http://www.unix.com/shell-programming-and-scripting/59936-url-encoding.html

   echo $(echo $1 | sed -f $URLENCODE);
}

urlDecode() {
   # Title            : urlDecode
   # Function         : URLDecodes a string received
   # Input            : string
   # Output           : Decoded string
   # Last modified by : Raymond van den Heuvel
   # Modification date:
   # Origin           : http://www.unix.com/shell-programming-and-scripting/59936-url-encoding.html

   echo $(echo $1 | sed -f $URLDECODE);
}

createDirectory() {
  # Title            : createDirectory
  # Function         : Creates the directory which has been given as argument
  # Input            : full directorypath
  # Output           : On error ERROR_CREATING_DIRECTORY
  # Last modified by : Raymond van den Heuvel
  # Modification date: 

   directory="$1";
   if [ ${#directory} -gt 0 ]; then
      result=$(mkdir "$directory" 2>&1);
      status=$?;
      if [ $status -eq 0 ]; then
         echo $(__ "%s: %s directory %s created" "$(date +%X)" "$remoteAddress" "$directory" ) >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s directory %s not created! Error: %s" "$(date +%X)" "$remoteAddress"  $directory "$result") >> $SYSTEMLOGFILE;
         return_message "ERROR_CREATING_DIRECTORY";
      fi
   fi
}

changeOwnership() {
  # Title            : changeOwnership
  # Function         : changes the ownershipp on the directory given as argument, to user:group given as argument
  # Input            : full directorypath, username, groupname
  # Output           : on error ERROR_CHANGING_OWNERSHIP, ERROR_DIRECTORY_NOT_EXIST_changeOwnership
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   directory="$1";
   userName=$2;
   groupName=$3;

   if [ ${#directory} -gt 0 ] && [ ${#userName} -gt 0 ] && [ ${#groupName} -gt 0 ]; then
	if [ -d "$directory" ]; then
	   #Changing directory ownership
           result=$(chown $userName:$groupName "$directory" 2>&1);
           status=$?;
           if [ $status -eq 0 ]; then
              echo $(__ "%s: %s directory %s owner changed to %s:%s" "$(date +%X)" "$remoteAddress" "$directory" "$userName" "$groupName" ) >> $SYSTEMLOGFILE;
           else
              echo $(__ "%s: %s directory %s owner not changed! Error: %s" "$(date +%X)" "$remoteAddress" "$directory" "$result") >> $SYSTEMLOGFILE;
              return_message "ERROR_CHANGING_OWNERSHIP";
           fi
	else
           echo $(__ "%s: %s directory %s not found!" "$(date +%X)" "$remoteAddress" "$directory") >> $SYSTEMLOGFILE;
           return_message "ERROR_DIRECTORY_NOT_EXIST_changeOwnership";
	fi
   fi
} 

verifyModuleHash(){
  # Title            : verifyModuleHash
  # Function         : verifies the hash of the module belonging to the given signed definition file
  # Input            : Signed Definition file
  # Output           : Full filename (including path) of the imagefile, on error MODULE_HASH_DOES_NOT_MATCH
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   file=$1

   if [ -f $file ]; then
      modInfo=$(verifyAndDecrypt $file)

      if [ ${#modInfo} -gt 0 ]; then
         fileHash=$(getDefinitionItem "hash" "$modInfo" | tr -d '"')
         modFileName=${file%.definition.gpg}".img"
         modFileHash=$(md5sum $modFileName | cut -d ' ' -f 1)

         if [ "$modFileHash" = "$fileHash" ]; then
	    echo $(__ "%s: %s successfully verified module hash belonging to %s" "$(date +%X)" "$remoteAddress" "$file")  >> $SYSTEMLOGFILE
	    echo "$modFileName";
         else
	    echo $(__ "%s: %s error verifying module hash belonging to %s" "$(date +%X)" "$remoteAddress" "$file")  >> $SYSTEMLOGFILE
            return_message "MODULE_HASH_DOES_NOT_MATCH";
         fi

      fi
   fi

}

unmountCaseFolders() {
  # Title            : unmountCaseFolders
  # Function         : Umounts all folders with caseid
  # Input            : caseid
  # Output           :
  # Last modified by : Raymond van den Heuvel
  # Modification date:

  caseID=$1

  if [ ${#caseID} -gt 0 ]; then
     mounts=$(mount | grep -e $caseID | cut -d ' ' -f 3 | sort -r)

     for mount in $mounts
     do
        result=$(umount $mount 2>&1)
	status=$?
	if [ $status -ne 0 ]; then
           echo $(__ "%s: %s error unmounting %s: %s" "$(date +%X)" "$remoteAddress" "$mount" "$result") >> $SYSTEMLOGFILE
	   return_message "ERROR_UNMOUNTING";
	   exit;
	else
	   echo $(__ "%s: %s umounted %s" "$(date +%X)" "$remoteAddress" "$mount") >> $SYSTEMLOGFILE
	fi
     done
  fi
}


checkCaseDirectories(){
  # Title            : checkCaseDirectories
  # Function         : Checks for a specifiic caseis whether the data directories are create and the rights are set
  # Input            : CaseID
  # Output           : Status message
  # Last modified by : Raymond van den Heuvel
  # Modification date: 

  caseID=$1
  if [ ${#caseID} -gt 0 ]; then
     caseConfig="$FIRESTOR/$caseID/conf/case.conf"
     caseDataDir="$FIRESTOR/$caseID/data"
     if [ -f $caseConfig ]; then
        if [ ! -d $caseDataDir ]; then
	   result=$(mkdir $caseDataDir 2>&1);
	   status=$?
	   if [ $status -eq 0 ]; then
	      echo $(__ "%s: %s directory %s created" "$(date +%X)" "$remoteAddress" "$caseDataDir") >> $SYSTEMLOGFILE;
	   else
	      echo $(__ "%s: %s directory %s not created! Error: %s" "$(date +%X)" "$remoteAddress" "$caseDataDir" "$result") >> $SYSTEMLOGFILE;
	      return_message "ERROR_CREATING_DIRECTORY";
	   fi
	fi
        if [ -d $caseDataDir ]; then
	   accountSection=$(readFileSection $caseConfig "Section:Case-UID-Begin" "Section:Case-UID-END");
	   if [ ${#accountSection} -eq 0 ]; then
	      return_message "NO_ACCOUNT_SECTION_FOUND";
	   fi
	
	   moduleSection=$(readFileSection $caseConfig "Section:Case-Modules-Begin" "Section:Case-Modules-END");
	   if [ ${#moduleSection} -eq 0 ]; then
	      return_message "NO_MODULE_SECTION_FOUND"
	   fi

	   OFS=$IFS;
	   IFS=$(echo "\n\b");
	   for modLine in $moduleSection
	   do
	      modUserName=$(echo "$modLine" | cut -d ',' -f 2);
              modModuleName=$(echo "$modLine" | cut -d ',' -f 5 | sed -e 's/^"//'  -e 's/"$//');
	      moduleFolder=$caseDataDir"/"$modModuleName
	      if [ ! -d $moduleFolder ]; then
	         createDirectory $moduleFolder
	         
                 for accLine in $accountSection
	         do
	            accType=$(echo $accLine | cut -d ',' -f 2);
	            accUserName=$(echo $accLine | cut -d ',' -f 3);
	            accGroupName=$(echo $accLine | cut -d ',' -f 5);
		    if [ $accType = "case" ]; then
		       changeOwnership $caseDataDir root $accGroupName
		    elif [ "$accUserName" = "$modUserName" ]; then
		       changeOwnership "$moduleFolder" $accUserName $accGroupName
		    fi
                 done
	      fi
	   done
	   IFS=$OFS;
        fi
     else
        return_message "CASE_CFG_NOTFOUND";
     fi
   else
      return_message "CHECK_INPUT";
   fi
}


startCase(){
  # Title            : startCase
  # Function         : Start a Case, create users/groups, create directories, mount directories/modules, start webserver(s)
  # Input            : caseid
  # Output           :
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  
  caseID=$1

  if [ ${#caseID} -gt 0 ]; then
     caseConfig="$FIRESTOR/$caseID/conf/case.conf"
     if [ -f $caseConfig ]; then
 	#Read accountsection
	accountSection=$(readFileSection $caseConfig "Section:Case-UID-Begin" "Section:Case-UID-END");
	if [ ${#accountSection} -eq 0 ]; then
	   return_message "NO_ACCOUNT_SECTION_FOUND";
	fi
	#Read modulessection
        moduleSection=$(readFileSection $caseConfig "Section:Case-Modules-Begin" "Section:Case-Modules-END");
	if [ ${#moduleSection} -eq 0 ]; then
	   return_message "NO_MODULE_SECTION_FOUND"
	fi

	#Let's test if de module locations are available
        for modLine in $moduleSection
        do
           modModule=$(echo "$modLine" | cut -d ',' -f 3);

           if isSubString $USBMODMODULELOCATION $modModule;then
              if ! isMounted $USBMODMODULELOCATION;then
                 return_message "USBMODULELOCATION_NOT_MOUNTED";
                 exit;
              fi
           fi
           if isSubString $FBMODULELOCATION $modModule;then
              if [ ! -d $FBMODULELOCATION ];then
                 return_message "INTERNALMODULELOCATION_NOT_AVAILABLE";
                 exit;
              fi
           fi
        done

	createAccounts $caseID;
        checkCaseDirectories $caseID;

	if [ ! -d "/tmp/"$caseID ]; then
	   result=$(mkdir "/tmp/"$caseID 2>&1);
 	   status=$?;
	   if [ $status -eq 0 ]; then
	      echo $(__ "%s: %s directory %s created" "$(date +%X)" "$remoteAddress" "/tmp/"$caseID) >> $SYSTEMLOGFILE;
	   else
	      echo $(__ "%s: %s directory %s not created! Error: %s" "$(date +%X)" "$remoteAddress" "/tmp/"$caseID "$result") >> $SYSTEMLOGFILE;
	      return_message "ERROR_CREATING_DIRECTORY";
	   fi
	fi

	for accLine in $accountSection
	do
	   accCaseNR=$(echo $accLine | cut -d ',' -f 1);
	   accType=$(echo $accLine | cut -d ',' -f 2);
	   accUserName=$(echo $accLine | cut -d ',' -f 3);
	   accUserID=$(echo $accLine | cut -d ',' -f 4);
	   accGroupName=$(echo $accLine | cut -d ',' -f 5);
	   accGroupID=$(echo $accLine | cut -d ',' -f 6);

	   # Create directories
	   directoryNS="/tmp/"$caseID"/"$accUserName
	   directoryUnion="/tmp/"$caseID"/"$accUserName"Union"

	   if [ ! -d $directoryNS ] && [ $accType = "module" ]; then
		#Create direcory
		createDirectory $directoryNS
		createDirectory $directoryUnion
		#Directory Created, change ownership
		changeOwnership $directoryNS $accUserName "root"
		changeOwnership $directoryUnion $accUserName "root"
		#Ownership changed

		OFS=$IFS;
		IFS=$(echo "\n\b");
	 	for modLine in $moduleSection
		do
		    modUserName=$(echo "$modLine" | cut -d ',' -f 2);

		    if [ "$modUserName" = "$accUserName" ]; then
		    	modModule=$(echo "$modLine" | cut -d ',' -f 3);
		    	modHttpPort=$(echo "$modLine" | cut -d ',' -f 4);
		    	modModuleName=$(echo "$modLine" | cut -d ',' -f 5 | sed -e 's/^"//'  -e 's/"$//');

			# Check if module location is available
			moduleLocationAvailable $modModule
			# If we ended up here it is, let's mount the module

			moduleName=$(verifyModuleHash $modModule);
			if [ "$moduleName" != "MODULE_HASH_DOES_NOT_MATCH" ]; then
			    if [ -f $moduleName ]; then
				modMountPoint="/mnt/"$(basename $moduleName);
				mountDisk $moduleName $modMountPoint "loopdev";

				# Bind the firebrick root to the modules directory
				result=$(mount --bind / $directoryNS);
	 			status=$?;
	 			if [ $status -ne 0 ]; then
            			   echo $(__ "%s: %s error binding / to %s: %s" "$(date +%X)" "$remoteAddress" "$directoryNS" "$result" ) >> $SYSTEMLOGFILE
	    			   return_message "ERROR_BINDING";
	 			else
	    			   echo $(__ "%s: %s / bound to %s" "$(date +%X)" "$remoteAddress" "$directoryNS") >> $SYSTEMLOGFILE
	 			fi
				
				# Create UNIONFS mounting the module root and overlay the module
				if [ "$devel" = "1" ]; then
                                   result=$(unionfs-fuse -o allow_other $modMountPoint=ro:$directoryNS $directoryUnion);
                                else
                                   result=$(unionfs -o allow_other $modMountPoint=ro:$directoryNS $directoryUnion);
                                fi
	 			status=$?;
	 			if [ $status -ne 0 ]; then
            			   echo $(__ "%s: %s error creating unionfs: %s and %s: %s" "$(date +%X)" "$remoteAddress" "$modMountPoint" "$directoryNS" "$result") >> $SYSTEMLOGFILE
	    			   return_message "ERROR_CREATING_UNIONFS";
	 			else
	    			   echo $(__ "%s: %s %s and %s united on %s" "$(date +%X)" "$remoteAddress" "$modMountPoint" "$directoryNS" "$directoryUnion") >> $SYSTEMLOGFILE
	 			fi

				# Bind the Case data directory to the UNIONFS
				result=$(mount --bind $FIRESTOR/$caseID/data $directoryUnion$FIRESTOR);
	 			status=$?;
	 			if [ $status -ne 0 ]; then
            			   echo $(__ "%s: %s error binding %s to %s: %s" "$(date +%X)" "$remoteAddress" "$FIRESTOR/$caseID/data" "$directoryUnion$FIRESTOR" "$result" ) >> $SYSTEMLOGFILE
	    			   return_message "ERROR_BINDING";
	 			else
	    			   echo $(__ "%s: %s %s bound to %s" "$(date +%X)" "$remoteAddress" "$FIRESTOR/$caseID/data" "$directoryUnion$FIRESTOR") >> $SYSTEMLOGFILE
	 			fi
			    fi

		           # Start the webserver
		           startHttpd=$(chroot $directoryUnion /bin/busybox httpd -v -p $modHttpPort -u $modUserName -h /var/www/ 2>&1)
		           status=$?
	 	           if [ $status -ne 0 ]; then
            	              echo $(__ "%s: %s error starting webserver" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE
	    	              return_message "ERROR_STARTING_WEBSERVER";
	 	           else
	    	              echo $(__ "%s: %s webserver started on port %s" "$(date +%X)" "$remoteAddress" "$modHttpPort") >> $SYSTEMLOGFILE
	 	    	   fi
			else
			    return_message "HASH_VERIFICATION_FAILED";
			fi
		    fi
		done
		IFS=$OFS;
	   fi
	done
      else
         return_message "CASE_CONFIG_NOT_FOUND";
      fi
   else
     return_message "CHECK_INPUT";
   fi
   return_message "CASE_OPENED";
}

closeCase(){
  # Title            : closeCase
  # Function         : Close a Case, kill webserver(s), unmount directories/modules, delete directories, remove users/groups
  # Input            : caseid
  # Output           : 
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  
  caseID=$1

  if [ ${#caseID} -gt 0 ]; then
     caseConfig="$FIRESTOR/$caseID/conf/case.conf"

     if [ -f $caseConfig ]; then
	accountSection=$(readFileSection $caseConfig "Section:Case-UID-Begin" "Section:Case-UID-END");
	if [ ${#accountSection} -eq 0 ]; then
	   return_message "NO_ACCOUNT_SECTION_FOUND";
	fi

        moduleSection=$(readFileSection $caseConfig "Section:Case-Modules-Begin" "Section:Case-Modules-END");
	if [ ${#moduleSection} -eq 0 ]; then
	   return_message "NO_MODULE_SECTION_FOUND"
	fi

	for accLine in $accountSection
	do
	   accUserName=$(echo $accLine | cut -d ',' -f 3);
	   accType=$(echo $accLine | cut -d ',' -f 2);
	   accGroupName=$(echo $accLine | cut -d ',' -f 5);

           if [ $accType != "case" ]; then
	      #Get processID beloning to user
	      if [ "$devel" = "1" ]; then
                 userProcs=$( /bin/busybox ps | grep $accUserName | grep -v unionfs | grep -v grep | tr -s ' ' | cut -d ' ' -f 1 );
	      else
                 userProcs=$( /bin/busybox ps | grep $accUserName | grep -v unionfs | grep -v grep | tr -s ' ' | cut -d ' ' -f 2 );
              fi
	      for procId in $userProcs
	      do
	         result=$(kill $procId 2>&1);
	         status=$?;
	         if [ $status -ne 0 ]; then
	            echo $(__ "%s: %s process with id %s could not be terminated, restart the firebrick! Error: %s" "$(date +%X)" "$remoteAddress" "$procId" "$result") >> $SYSTEMLOGFILE;
	            return_message "ERROR_TERMINATING_PROCESSES";
	            exit;
	         else
	            echo $(__ "%s: %s process with id %s terminated" "$(date +%X)" "$remoteAddress" "$procId") >> $SYSTEMLOGFILE;
	         fi
	      done

	      #Remove Useraccount
	      if [ "$devel" = "1" ]; then
	         result=$(userdel $accUserName 2>&1);
	      else
	         result=$(deluser $accUserName 2>&1);
	      fi
	      status=$?
	      if [ $status -eq 0 ]; then
	         echo $(__ "%s: %s user %s removed" "$(date +%X)" "$remoteAddress" "$accUserName") >> $SYSTEMLOGFILE;
	      else
	         echo $(__ "%s: %s user %s could not be removed! %s" "$(date +%X)" "$remoteAddress" "$accUserName" "$result") >> $SYSTEMLOGFILE;
	         #return_message "ERROR_DELETING_USER";
                 #exit;
	      fi
	   fi
        done

        if [ "$devel" = "1" ]; then
	   result=$(groupdel $accGroupName 2>&1);
        else
	   result=$(delgroup $accGroupName 2>&1);
        fi
	status=$?
	if [ $status -eq 0 ]; then
	   echo $(__ "%s: %s group %s removed" "$(date +%X)" "$remoteAddress" "$accGroupName") >> $SYSTEMLOGFILE;
	else
	   echo $(__ "%s: %s group %s could not be removed! %s" "$(date +%X)" "$remoteAddress" "$accGroupName" "$result") >> $SYSTEMLOGFILE;
	   #return_message "ERROR_DELETING_GROUP";
           #exit;
	fi

	#Umount all directories mounted on /tmp/$caseID
	unmountCaseFolders $caseID

	#Remove caseID direcotry from /tmp
	if [ -d "/tmp/"$caseID ]; then
	   result=$(rm -Rf "/tmp/"$caseID 2>&1);
 	   status=$?;
	   if [ $status -eq 0 ]; then
	      echo $(__ "%s: %s directory %s removed" "$(date +%X)" "$remoteAddress" "/tmp/"$caseID) >> $SYSTEMLOGFILE;
	   else
	      echo $(__ "%s: %s directory %s could not be removed! Error: %s" "$(date +%X)" "$remoteAddress" "/tmp/"$caseID "$result") >> $SYSTEMLOGFILE;
	      return_message "ERROR_DELETING_DIRECTORY";
	   fi
	fi

	OFS=$IFS;
	IFS=$(echo "\n\b");

	for modLine in $moduleSection
	do
	   modUserName=$(echo "$modLine" | cut -d ',' -f 2);
	   modModule=$(echo "$modLine" | cut -d ',' -f 3);
           modMountPoint="/mnt/"$(basename $modModule | cut -d '.' -f1)".img";
	   result=$(mount | grep $modMountPoint | cut -d ' ' -f 3)
	   if [ "$result" = $modMountPoint ]; then
	      result=$(umount $modMountPoint 2>&1);
	      status=$?
	      if [ $status -eq 0 ]; then
		 echo $(__ "%s: %s mountpoint %s unmouted" "$(date +%X)" "$remoteAddress" "$modMountPoint") >> $SYSTEMLOGFILE;
		 result=$(rmdir "$modMountPoint")
		 status=$?
		 if [ $status -eq 0 ]; then
		    echo $(__ "%s: %s directory %s removed" "$(date +%X)" "$remoteAddress" "$modMountPoint") >> $SYSTEMLOGFILE;
		 else
		    echo $(__ "%s: %s directory %s could not be removed! %s" "$(date +%X)" "$remoteAddress" "$modMountPoint" "$result") >> $SYSTEMLOGFILE;
		    return_message "ERROR_DELETING_DIRECTORY";
		 fi
	      else
		 echo $(__ "%s: %s mountpoint %s could not be unmounted: %s" "$(date +%X)" "$remoteAddress" "$modMountPoint" "$result") >> $SYSTEMLOGFILE;
		 return_message "ERROR_UMOUNTING";
	      fi
	   else
	      echo $(__ "%s: %s mountpoint %s is not mounted." "$(date +%X)" "$remoteAddress" "$modMountPoint") >> $SYSTEMLOGFILE;
	   fi
        done
	IFS=$OFS;
      else
         return_message "CASE_CONFIG_NOT_FOUND";
      fi
   else
     return_message "CASE_INPUT_startCase";
   fi
   echo "CASE_CLOSED";
}

caseMaster(){
  # Title            : caseMaster
  # Function         : opens, closed, reopens or closes a case with status information. This is a wrapper function for additional functionality
  #                    as reopen case at restart
  # Input            : caseid and case command reopen, open, closereopen, close
  # Output           : 
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   caseCommand=$1;
   caseID=$2;
   if [ ! -d $FBSTATUSLOCATION ]; then
      result=$(mkdir $FBSTATUSLOCATION 2>&1);
      status=$?;
      if [ $status -eq 0 ]; then
	 echo $(__ "%s: %s created status directory." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE; 
      else
	 echo $(__ "%s: %s error creating status directory %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
	 return_message "ERROR_MOVING_FILE";
      fi
   fi

   if [ ${#caseCommand} -gt 0 ]; then
      if [ "$caseCommand" = "reopen" ]; then
	 #Try to reopen a case based on the REOPENCASE status file
	 directory=$FBSTATUSLOCATION
	 if [ -f $directory"/REOPENCASE" ]; then
            reopenedCase=$(cat $directory"/REOPENCASE");
            echo $(__ "%s: %s REOPENCASE file has been found with caseid %s" "$(date +%X)" "$remoteAddress" "$reopenedCase") >> $SYSTEMLOGFILE;
	    result=$(mv $directory"/REOPENCASE" $directory"/OPENCASE" 2>&1);
	    status=$?;
	    if [ $status -eq 0 ]; then
		echo $(__ "%s: %s moved REOPENCASE to OPENCASE status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    else
		echo $(__ "%s: %s error moving REOPENCASE to OPENCASE status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	        return_message "ERROR_MOVING_FILE";
	    fi
	    startCase $reopenedCase;
         else
            echo $(__ "%s: %s REOPENCASE status-file not found, cannot reopen case." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    return_message "ERROR_CANNOT_REOPEN";
         fi
      elif [ ${#caseID} -gt 0 ] && [ "$caseCommand" = "open" ]; then
	 #Try to open a case with the provided ID, REOPENCASE status file wil be deleted
	 directory=$FBSTATUSLOCATION
	 if [ ! -d $directory ]; then
	    restult=$(mkdir $directory 2>&1);
	    if [ $status -gt 0 ]; then
		echo $(__ "%s: %s error creating state directory on firestor." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
		return_message "ERROR_CREATING_DIRECTORY";
		exit;
	    fi
         fi
         if [ -f $directory"/REOPENCASE" ];then
	    echo $(__ "%s: %s REOPENCASE file was found, removing status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    result=$(rm $directory"/REOPENCASE" 2>&1);
	    status=$?;
	    if [ $status -eq 1 ]; then
	       echo $(__ "%s: %s error removing REOPENCASE status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    fi
	 fi
	 echo $caseID > $directory"/OPENCASE";
	 startCase $caseID;
      elif [ "$caseCommand" = "closereopen" ]; then
         #Close the case but write cadeID to REOPENCASE file for reopen last case option
	 directory=$FBSTATUSLOCATION
         if [ -f $directory"/OPENCASE" ]; then
            openCase=$(cat $directory"/OPENCASE");
            echo $(__ "%s: %s moving OPENCASE to REOPENCASE file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    result=$(mv $directory"/OPENCASE" $directory"/REOPENCASE" 2>&1);
	    status=$?;
	    if [ $status -eq 1 ]; then
	       echo $(__ "%s: %s error moving OPENCASE to REOPENCASE status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    fi
      	    closeCase $openCase;
	 fi
      elif [ "$caseCommand" = "close" ]; then
	 #Close the case with the provided ID, but also check the OPENCASE status file
	 directory=$FBSTATUSLOCATION
         if [ -f $directory"/OPENCASE" ]; then
            openCase=$(cat $directory"/OPENCASE");
	    result=$(rm $directory"/OPENCASE" 2>&1);
	    status=$?;
	    if [ $status -eq 1 ]; then
	       echo $(__ "%s: %s error removing OPENCASE status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    fi
	    closeCase $openCase;
	 fi
      elif [ "$caseCommand" = "cancelreopen" ]; then
	 directory=$FBSTATUSLOCATION;
         if [ -f $directory"/REOPENCASE" ]; then
 	    echo $(__ "%s: %s canceling reopen case." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;           
	    result=$(rm $directory"/REOPENCASE" 2>&1);
	    status=$?;
	    if [ $status -eq 1 ]; then
	       echo $(__ "%s: %s error removing REOPENCASE status-file." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    fi
            return_message "REOPEN_CANCELED";
	 fi
      elif [ "$caseCommand" = "iscaseopen" ]; then
	 directory=$FBSTATUSLOCATION;
         if [ -f $directory"/OPENCASE" ]; then
 	    echo $(__ "%s: %s a case is currently opended." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
            caseopened=$(cat $directory"/OPENCASE")
            return_message "CASE_OPENED_"$caseopened;
	 fi
      elif [ "$caseCommand" = "reopenstate" ]; then
	 #Try to reopen a case based on the REOPENCASE status file
	 directory=$FBSTATUSLOCATION
	 if [ -f $directory"/REOPENCASE" ]; then
            reopenedCase=$(cat $directory"/REOPENCASE");
            echo $(__ "%s: %s REOPENCASE file has been found with caseid %s" "$(date +%X)" "$remoteAddress" "$reopenedCase") >> $SYSTEMLOGFILE;
	    return_message "SCHED_REOPEN_$reopenedCase";
         else
            echo $(__ "%s: %s no REOPENCASE file found." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	    return_message "NO_SCHED_REOPEN";
         fi
      else
	 return_message "CHECK_INPUT";
      fi
   fi
}

moduleLocationAvailable() {
  # Title            : moduleLocationAvailable
  # Function         : Check whether the modules location is available
  # Input            : Full module path including modules name
  # Output           : On error: CHECK_INPUT, 0, 1
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   moduleLocation=$1
     if [ ${#moduleLocation} -gt 0 ]; then
      result=$(isSubString $USBMODMODULELOCATION $moduleLocation);
      status=$?;

      if [ $status -eq 0 ]; then
         #Module is located on USB storage
         result=$(isMounted $USBMODMODULELOCATION);
         status=$?;
         if [ "$status" -eq 1 ]; then
	    echo $(__ "%s: %s error USB-storage not mounted." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
            return_message "USBMODULELOCATION_NOT_MOUNTED";
	    exit;
         fi
         return 0;
      fi

      result=$(isSubString $FBMODULELOCATION $moduleLocation);
      status=$?;
      if [ $status -eq 0 ]; then
         if [ ! -d $FBMODULELOCATION ]; then
	    echo $(__ "%s: %s error internal module location not available" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
            return_message "INTERNALMODULELOCATION_NOT_AVAILABLE";
	    exit;
         fi
         return 0;
      fi
      echo $(__ "%s: %s module location not known %s" "$(date +%X)" "$remoteAddress" "$moduleLocation") >> $SYSTEMLOGFILE;
      return_message "UNKNOWN_MODULELOCATION_INT";
   else
      return_message "CHECK_INPUT";
      exit;
   fi
}

getModuleDefinitions(){
  # Title            : getModuleDefinitions
  # Function         : Gets module information from given module storage
  # Input            : USB, INTERNAL
  # Output           : On error: CHECK_INPUT, otherwise returns json strucutre of module data
  # Last modified by : Raymond van den Heuvel
  # Modification date:
  
   location=$1
   if [ $location = "USB" ]; then
	  moduleLocationAvailable $USBMODMODULELOCATION
	  definitionDataToJSON $USBMODMODULELOCATION"/*.gpg"
   elif [ $location = "INTERNAL" ]; then
	  moduleLocationAvailable $FBMODULELOCATION;
	  definitionDataToJSON $FBMODULELOCATION"/*.gpg";
   else
      return_message "CHECK_INPUT";
   fi

}

casesToJSON () {
  # Title            : casesToJSON
  # Function         : Generate a JSON formatted data structure of the cases on the firestor
  # Input            : -
  # Output           : JSON structured information
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   count=0

   cases=$(cd $FIRESTOR; ls -d */ | cut -d '/' -f 1 | grep -v lost+found);

   OFS=$IFS;
   IFS=$(echo "\n\b");
   for case in $cases
   do
      if [ ${#case} -gt 0 ]; then
         if [ "$count" -eq 0 ]; then
 	    echo '{"cases":[';
            echo -n '   {';
 	    count=1;
	 else
	    echo -n '  ,{'
         fi
         echo ' "caseid": "'$case'" }';
      fi
   done
   echo ']}';
   IFS=$OFS;
}

caseLinkedModulesJSON () {
  # Title            : caseModulesToJSON
  # Function         : Generate a JSON formatted data structure of the modules linked to a given case
  # Input            : caseid
  # Output           : JSON structured information
  # Last modified by : Raymond van den Heuvel
  # Modification date:

   caseid=$1
   if [ ${#caseid} -gt 0 ]; then
      caseConfigFile=$FIRESTOR"/"$caseid"/conf/case.conf"
      modSectionBegin="Section:Case-Modules-Begin";
      modSectionEnd="Section:Case-Modules-END";

      currentModuleInfo=$(readFileSection $caseConfigFile $modSectionBegin $modSectionEnd);

      if [ ${#currentModuleInfo} -gt 0 ]; then
         count=0;
         OFS=$IFS;
         IFS=$(echo "\n\b");
         for info in $currentModuleInfo
         do
            caseid=$(echo $info | cut -d ',' -f 1)
            username=$(echo $info | cut -d ',' -f 2)
            filename=$(echo $info | cut -d ',' -f 3)
            httpP=$(echo $info | cut -d ',' -f 4)
            workdir=$(echo $info | cut -d ',' -f 5)
            if [ "$count" -eq 0 ]; then
 	       echo '{"modules":['
               echo '   {'
 	       count=1;
            else
	       echo '  },{'
            fi
            echo '     "caseid": "'$caseid'",'
            echo '     "usename": "'$username'",'
            echo '     "filename": "'$filename'",'
            echo '     "httpp": "'$httpP'",'
            echo '     "workdir": "'$workdir'"'
         done
         echo '}]}'
         IFS=$OFS
      else
	 return_message "NO_LINKED_MODULES";
      fi
   fi
}

storageInfoToJSON () {
   # Title            : storageInfoToJSON
   # Function         : Generate a JSON formatted data structure of the storage
   # Input            : -
   # Output           : JSON structured information
   # Last modified by : Raymond van den Heuvel
   # Modification date:

   if [ "$devel" = "1" ] && [ "$runningvirtual" = "0" ]; then
      storageDisk1="loop2"
      storageDisk2="loop3"
   elif [ "$runningvirtual" = "1" ]; then
      storageDisk1=$(ls -la /sys/block | grep ata. | grep host0 | grep target0:0:0 | grep -o sd. | tail -1)
      storageDisk2=$(ls -la /sys/block | grep ata. | grep host0 | grep target0:0:1 | grep -o sd. | tail -1)
   else
      storageDisk1=$(ls -la /sys/block | grep ata. | grep host2 | grep -o sd. | tail -1)
      storageDisk2=$(ls -la /sys/block | grep ata. | grep host3 | grep -o sd. | tail -1)
   fi
   
   result=$(isMounted $FIRESTOR);
   status=$?;
   if [ "$status" -eq 0 ]; then
      ismounted="1";
      filesystem=$(mount | grep "/firestor" | grep -v Union | cut -d ' ' -f 5);
      if [ "$filesystem" = "ext2" ]; then
	 fscorrect="1";
      else
	 fscorrect="0";
      fi
      blockdevice=$(mount | grep "/firestor" | grep -v Union | cut -d ' ' -f 1);
      if [ "$blockdevice" = "/dev/md0p1" ]; then
	 israid="1";
      else
	 israid="0";
      fi
   else
      ismounted="0";
      filesystem="0";
      blockdevice="0";
      fscorrect="0";
      israid="0";
   fi

   # check the situation with storage
   if [ ${#storageDisk1} -gt 2 ] && [ ${#storageDisk2} -gt 2 ]; then #RAID
      storageDevice="/dev/md0";
      disk1Size=$(cat "/sys/block/$storageDisk1/size");
      disk2Size=$(cat "/sys/block/$storageDisk2/size");
      echo '{"storage":['
      echo '            {';
      echo '             "firestor":[';
      echo '                      {"ismounted": "'$ismounted'", "fscorrect":"'$fscorrect'", "israid": "'$israid'", "filesystem":"'$filesystem'", "blockdevice": "'$blockdevice'"}';
      echo '             ],';
      echo '             "disks":[';
      echo '                      {"disk":"/dev/'$storageDisk1'", "size": "'$disk1Size'"},';
      echo '                      {"disk":"/dev/'$storageDisk2'", "size": "'$disk2Size'"}';
      echo '             ],';
      echo '             "raid":[';
      echo '                      {"storagedev": "'$storageDevice'"}'
      echo '             ]}';
      echo '           ]}';
   elif [ ${#storageDisk1} -gt 2 ]; then #single disk
      storageDevice="/dev/${storageDisk1}";
      disk1Size=$(cat "/sys/block/$storageDisk1/size");
      echo '{"storage":['
      echo '            {';
      echo '             "firestor":[';
      echo '                      {"ismounted": "'$ismounted'", "fscorrect":"'$fscorrect'", "israid": "'$israid'", "filesystem":"'$filesystem'", "blockdevice": "'$blockdevice'"}';
      echo '             ],';
      echo '             "disks":[';
      echo '                      {"disk":"/dev/'$storageDisk1'", "size": "'$disk1Size'"}';
      echo '             ],';
      echo '             "raid":[';
      echo '                      {"storagedev": "'$storageDevice'"}'
      echo '             ]}';
      echo '           ]}';
   elif [ ${#storageDisk2} -gt 2 ]; then #single disk
      storageDevice="/dev/${storageDisk2}";
      disk2Size=$(cat "/sys/block/$storageDisk2/size");
      echo '{"storage":['
      echo '            {';
      echo '             "firestor":[';
      echo '                      {"ismounted": "'$ismounted'", "fscorrect":"'$fscorrect'", "israid": "'$israid'", "filesystem":"'$filesystem'", "blockdevice": "'$blockdevice'"}';
      echo '             ],';
      echo '             "disks":[';
      echo '                      {"disk":"/dev/'$storageDisk2'", "size": "'$disk2Size'"}';
      echo '             ],';
      echo '             "raid":[';
      echo '                      {"storagedev": "'$storageDevice'"}'
      echo '             ]}';
      echo '           ]}';
   else
      storageDevice="--"
      echo '{"storage":['
      echo '            {';
      echo '             "firestor":[';
      echo '                      {"ismounted": "'$ismounted'", "fscorrect":"'$fscorrect'", "israid": "'$israid'", "filesystem":"'$filesystem'", "blockdevice": "'$blockdevice'"}';
      echo '             ],';
      echo '             "disks":[';
      echo '                      {"disk":"--No disks found--", "size": "--No RAID config--"}';
      echo '             ],';
      echo '             "raid":[';
      echo '                      {"storagedev": "'$storageDevice'"}'
      echo '             ]}';
      echo '           ]}';
   fi
}

initStorage (){
   # Title            : storageInfoToJSON
   # Function         : Generate a JSON formatted data structure of the storage
   # Input            : -
   # Output           : JSON structured information
   # Last modified by : Raymond van den Heuvel
   # Modification date:

   if [ "$devel" = "1" ] && [ "$runningvirtual" = "0" ]; then
      storageDisk1="loop2"
      storageDisk2="loop3"
   elif [ "$runningvirtual" = "1" ]; then
      storageDisk1=$(ls -la /sys/block | grep ata. | grep host0 | grep target0:0:0 | grep -o sd. | tail -1)
      storageDisk2=$(ls -la /sys/block | grep ata. | grep host0 | grep target0:0:1 | grep -o sd. | tail -1)
   else
      storageDisk1=$(ls -la /sys/block | grep ata. | grep host2 | grep -o sd. | tail -1)
      storageDisk2=$(ls -la /sys/block | grep ata. | grep host3 | grep -o sd. | tail -1)
   fi
   
   result=$(isMounted $FIRESTOR);
   status=$?;
   if [ "$status" -eq 0 ]; then
      # Unmount storage
      result=$(umount $FIRESTOR 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         SYSTEMLOGFILE="/system.log";
         echo $(__ "%s: %s firestor storage successfully unmounted" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error unable to unmount the firestor storage, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_TO_UMNOUNT_FIRESTOR";
	 exit;
      fi
   fi

   # check the situation with storage
   if [ ${#storageDisk1} -gt 2 ] && [ ${#storageDisk2} -gt 2 ]; then #RAID
      storageDevice="/dev/md0";

      if [ -e $storageDevice ]; then
         result=$(mdadm --remove $storageDevice 2>&1);
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s firestor RAID devices successfully removed" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         else
            echo $(__ "%s: %s error unable to remove firestor RAID device, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "UNABLE_TO_REMOVE_RAID";
	    exit;
         fi
         
	 result=$(mdadm --stop $storageDevice 2>&1);
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s firestor RAID devices successfully stopped" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         else
            echo $(__ "%s: %s error unable to stop firestor RAID device, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "UNABLE_TO_STOP_RAID";
	    exit;
         fi
      else
         echo $(__ "%s: %s no RAID device found %s" "$(date +%X)" "$remoteAddress" "$storageDevice") >> $SYSTEMLOGFILE;
      fi

      disk1Size=$(cat "/sys/block/$storageDisk1/size");
      disk2Size=$(cat "/sys/block/$storageDisk2/size");
      if [ $disk1Size = $disk2Size ]; then
         #Create RAID configuration
         result=$( echo "yes" | mdadm --create $storageDevice --level=1 --raid-devices=2 /dev/$storageDisk1 /dev/$storageDisk2 2>&1 );
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s RAID configuration successfully created" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         else
            echo $(__ "%s: %s error unable to create RAID configuration, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "UNABLE_CREATING_RAIDCFG";
	    exit;
         fi

	 sleep 1;
         echo $(__ "%s: %s Syncing disks" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
	 sync

         #Erase bootrecord
         result=$(dd if=/dev/zero of=$storageDevice bs=512 count=1 2>&1);
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s successfully erased bootrecord" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         else
            echo $(__ "%s: %s error erasing bootrecord, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "UNABLE_ERASING_BOOTRECORD";
	    exit;
         fi

         #Create partition 
         result=$( ( echo o; echo n; echo p; echo 1; echo 1; echo ; echo ; echo w ) | fdisk $storageDevice 2>&1);
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s successfully created partition on RAID device" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         else
            echo $(__ "%s: %s error unable to create partition on RAID device, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "UNABLE_CREATING_PARTITION";
	    exit;
         fi

	 sleep 1;

         #Create ext2 filesystem-structure
         result=$(mkfs.ext2 $storageDevice"p1" 2>&1);
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s successfully created filesystem structures" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         else
            echo $(__ "%s: %s error unable to create filesystem structures, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "UNABLE_CREATING_FSSTRUCTURES";
	    exit;
         fi

         #Mount firestor
         result=$(mount $storageDevice"p1" $FIRESTOR 2>&1);
         status=$?;
         if [ "$status" -eq 0 ]; then
            echo $(__ "%s: %s successfully mounted firestor" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
            return_message "FIRESTOR_MOUNTED";
         else
            echo $(__ "%s: %s error mounting firestor, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
            return_message "ERROR_MOUNTING_FIRESTOR";
	    exit;
         fi
      else
         echo $(__ "%s: %s tried to create RAID configuration but the HDD's have different sizes." "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         return_message "SIZE_IS_DIFFERENT";
      fi
   elif [ ${#storageDisk1} -gt 2 ]; then #single disk
      storageDevice="/dev/$storageDisk1";

      #Erase bootrecord
      result=$(dd if=/dev/zero of=$storageDevice bs=512 count=1 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully erased bootrecord" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error erasing bootrecord, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_ERASING_BOOTRECORD";
	 exit;
      fi

      echo $(__ "%s: %s Syncing disks" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      sync

      #Create partition 
      result=$( ( echo o; echo n; echo p; echo 1; echo 1; echo ; echo ; echo w ) | fdisk $storageDevice 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully created partition on RAID device" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error unable to create partition on RAID device, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_CREATING_PARTITION";
	 exit;
      fi

      #Create ext2 filesystem-structure
      result=$(mkfs.ext2 $storageDevice"1" 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully created filesystem structures" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error unable to create filesystem structures, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_CREATING_FSSTRUCTURES";
	 exit;
      fi

      #Mount firestor         
      result=$(mount $storageDevice $FIRESTOR 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully mounted firestor" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         return_message "FIRESTOR_MOUNTED";
      else
         echo $(__ "%s: %s error mounting firestor, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "ERROR_MOUNTING_FIRESTOR";
	 exit;
      fi
   elif [ ${#storageDisk2} -gt 2 ]; then #single disk
      storageDevice="/dev/$storageDisk2";

      #Erase bootrecord
      result=$(dd if=/dev/zero of=$storageDevice bs=512 count=1 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully erased bootrecord" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error erasing bootrecord, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_ERASING_BOOTRECORD";
	 exit;
      fi

      echo $(__ "%s: %s Syncing disks" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      sync

      #Create partition 
      result=$( ( echo o; echo n; echo p; echo 1; echo 1; echo ; echo ; echo w ) | fdisk $storageDevice 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully created partition on RAID device" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error unable to create partition on RAID device, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_CREATING_PARTITION";
	 exit;
      fi

      #Create ext2 filesystem-structure
      result=$(mkfs.ext2 $storageDevice"1" 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully created filesystem structures" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
      else
         echo $(__ "%s: %s error unable to create filesystem structures, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "UNABLE_CREATING_FSSTRUCTURES";
	 exit;
      fi

      #Mount firestor
      result=$(mount $storageDevice $FIRESTOR 2>&1);
      status=$?;
      if [ "$status" -eq 0 ]; then
         echo $(__ "%s: %s successfully mounted firestor" "$(date +%X)" "$remoteAddress") >> $SYSTEMLOGFILE;
         return_message "FIRESTOR_MOUNTED";
      else
         echo $(__ "%s: %s error mounting firestor, %s." "$(date +%X)" "$remoteAddress" "$result") >> $SYSTEMLOGFILE;
         return_message "ERROR_MOUNTING_FIRESTOR";
	 exit;
      fi
   else
      storageDevice="--"
      return_message "NO_STORAGEDEVICES_AVAIL";
   fi

}

