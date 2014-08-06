function isNumber(n) {
   return n == parseFloat(n);
}

function isEven(n) {
   return isNumber(n) && (n % 2 == 0);
}

function isOdd(n) {
   return isNumber(n) && (Math.abs(n) % 2 == 1);
}

function sanitizeString(str){
    str = str.replace(/[^a-z0-9áéíóúñü \.,_-]/gim,"");
    return str.trim();
}

function resizeContent() {
        var windowHeight = $(window).height() - 4;/* get the browser visible height on screen */
        var windowWidth = $(window).width() - 4; /* get the browser visible width on screen */
        var headerHeight = $('#top').height();/* get the header visible height on screen */
        var menuWidth = $('#menu').width();/* get the menu visible width on screen */
        var newMainHeight = windowHeight - headerHeight;
        var newContentWidth = windowWidth - menuWidth;
        if(newMainHeight > 0) {
            $('#main').height(newMainHeight);
            $('#menu').height(newMainHeight - 9);
            $('#content').height(newMainHeight - 9);
            /*$('#mainframe').height(newMainHeight - 11);*/
        }
        if(newContentWidth > 0) {
        	$('#content').width(newContentWidth - 1);
        	/*$('#mainframe').width(newContentWidth -13.5);*/
        }
}

function loadMenu(){
	var htmlMenu = new String();
	$.getJSON('./menu.json', function(data) {
	var countMenuItems = 0;
	var countSubMenuItems = 0;
	var objMenuItem = new Object();
	var objSubMenuItem = new Object();	
	for(_obj in data.menu) countMenuItems++;
	var menuItemCount = 0;
	var subMenuItemCount = 0;
	htmlMenu = '<br><ul id="Slidemenu" class="menu">';
	while (menuItemCount < countMenuItems ) {
		objMenuItem = data.menu[menuItemCount];
		htmlMenu += '<li class="node"><h2 class="menutitle" id="' + objMenuItem.menuitem + '">' + objMenuItem.menutext + '</h2><ul id="' + objMenuItem.menugroup + '">';
		if (typeof objMenuItem.submenu != "undefined"){
			for(_objSub in objMenuItem.submenu) countSubMenuItems++;
			while(subMenuItemCount < countSubMenuItems){
				objSubMenuItem = objMenuItem.submenu[subMenuItemCount];
				if (isOdd(subMenuItemCount)){
					if (/javascript:/.test(objSubMenuItem.url)){
						htmlMenu += '<li class="menuli_style1"><a target="mainframe" onClick="' + objSubMenuItem.url + '">' + objSubMenuItem.submenutext + '</a></li>';	
					}
					else{
						htmlMenu += '<li class="menuli_style1"><a href="' + objSubMenuItem.url + '" id="' + objSubMenuItem.submenuitem + '" target="mainframe">' + objSubMenuItem.submenutext + '</a></li>';						
					}
				}
				else {
					if (/javascript:/.test(objSubMenuItem.url)){
						htmlMenu += '<li class="menuli_style2"><a target="mainframe" onClick="' + objSubMenuItem.url + '">' + objSubMenuItem.submenutext + '</a></li>';	
					}
					else{
						htmlMenu += '<li class="menuli_style2"><a href="' + objSubMenuItem.url + '" id="' + objSubMenuItem.submenuitem + '" target="mainframe">' + objSubMenuItem.submenutext + '</a></li>';						
					}
				}
				subMenuItemCount++;
				
			}
			subMenuItemCount = 0;
			htmlMenu += "<li class='menuli_spacer'>&nbsp;</li></ul></li>";
		}
		countSubMenuItems = 0;
		menuItemCount++;
	}
	htmlMenu += "</ul>";
	var menuDiv = document.getElementById("menu");
	menuDiv.innerHTML = htmlMenu;
	});
}

function loadCaseMenu(){
	var htmlMenu = new String();
    value = "command=getcasemenu";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'text/json', success: function(data){
       jsonCaseMenu = JSON.parse( data );
	   var countMenuItems = 0;
	   var countSubMenuItems = 0;
	   var objMenuItem = new Object();
	   var objSubMenuItem = new Object();	
	   for(_obj in jsonCaseMenu.menu) countMenuItems++;
	   var menuItemCount = 0;
	   var subMenuItemCount = 0;
	   htmlMenu = '<br><ul id="Slidemenu" class="menu">';
	   while (menuItemCount < countMenuItems ) {
		  objMenuItem = jsonCaseMenu.menu[menuItemCount];
		  htmlMenu += '<li class="node"><h2 class="menutitle" id="' + objMenuItem.menuitem + '">' + objMenuItem.menutext + '</h2><ul id="' + objMenuItem.menugroup + '">';
		  if (typeof objMenuItem.submenu != "undefined"){
			 for(_objSub in objMenuItem.submenu) countSubMenuItems++;
			 while(subMenuItemCount < countSubMenuItems){
				objSubMenuItem = objMenuItem.submenu[subMenuItemCount];
				if (isOdd(subMenuItemCount)){
					if (/javascript:/.test(objSubMenuItem.url)){
						htmlMenu += '<li class="menuli_style1"><a target="mainframe" onClick="' + objSubMenuItem.url + '">' + objSubMenuItem.submenutext + '</a></li>';	
					}
					else{
						htmlMenu += '<li class="menuli_style1"><a href="' + objSubMenuItem.url + '" id="' + objSubMenuItem.submenuitem + '" target="mainframe">' + objSubMenuItem.submenutext + '</a></li>';						
					}
				}
				else {
					if (/javascript:/.test(objSubMenuItem.url)){
						htmlMenu += '<li class="menuli_style2"><a target="mainframe" onClick="' + objSubMenuItem.url + '">' + objSubMenuItem.submenutext + '</a></li>';	
					}
					else{
						htmlMenu += '<li class="menuli_style2"><a href="' + objSubMenuItem.url + '" id="' + objSubMenuItem.submenuitem + '" target="mainframe">' + objSubMenuItem.submenutext + '</a></li>';						
					}
				}
				subMenuItemCount++;	
			 }
			 subMenuItemCount = 0;
			 htmlMenu += "<li class='menuli_spacer'>&nbsp;</li></ul></li>";
		  }
		  countSubMenuItems = 0;
		  menuItemCount++;
	   }
	   htmlMenu += "</ul>";
	   var menuDiv = document.getElementById("menu");
	   menuDiv.innerHTML = htmlMenu;
	   }});
}

function showModulesInLocation(){
    selection = jQuery('#modlocation option:selected').val();
    if (selection == 'INTERNAL' || selection == 'USB'){
       value = "command=getmodules&modlocation=" + selection;
       $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, contentType: 'text/json', success: function(data){
       	    var availmodules = document.getElementById("availmodules");
    	      	if ( data.replace(/(\r\n|\n|\r)/gm,"") == 'INTERNALMODULELOCATION_NOT_AVAILABLE' ) {
    	      		infomessage(data.replace(/(\r\n|\n|\r)/gm,""));
    	      	} 
    	      	else if ( data.replace(/(\r\n|\n|\r)/gm,"") == 'USBMODULELOCATION_NOT_MOUNTED' ){
    	      		infomessage(data.replace(/(\r\n|\n|\r)/gm,""));
    	      	} 
    	      	else if ( data.replace(/(\r\n|\n|\r)/gm,"") == 'UNKNOWN_MODULELOCATION' ) {
    	      		infomessage(data.replace(/(\r\n|\n|\r)/gm,""));
    	      		$("#availmodules").empty();
				    var newoption= document.createElement('option');
					newoption.text = "--Select module location--";
					newoption.value = "--Select module location--";
					availmodules.add(newoption, moduleItemCount);
					var infoDiv = document.getElementById("availmodinfodiv");
				    infoDiv.innerHTML = "";
    	      	} 
    	      	else if ( data.replace(/(\r\n|\n|\r)/gm,"") == 'CHECK_INPUT' ){
    	      		infomessage(data.replace(/(\r\n|\n|\r)/gm,""));
					$("#availmodules").empty();
				    var newoption= document.createElement('option');
					newoption.text = "--Select module location--";
					newoption.value = "--Select module location--";
					availmodules.add(newoption, moduleItemCount);
					var infoDiv = document.getElementById("availmodinfodiv");
				    infoDiv.innerHTML = "";
    	      	}
    	      	else {
    	      	   modulejsonData = JSON.parse( data );
				   var countModuleItems = 0;
				   var objModuleItem = new Object();
				   for(_obj in modulejsonData.modules){
				      countModuleItems++;
				   };
				   var moduleItemCount = 0;
				   $("#availmodules").empty();
				   while (moduleItemCount < countModuleItems ) {
		              objModuleItem = modulejsonData.modules[moduleItemCount];
					  
					  var newoption= document.createElement('option');
					  newoption.text = objModuleItem.modulename;
					  newoption.value = objModuleItem.modulename;
					  availmodules.add(newoption, moduleItemCount);
		              moduleItemCount++;
		           }
				}
			 }
 	   });
    }
 }

function showSelectedModuleInformation(){
    selection = jQuery('#availmodules option:selected').val();
    modSelect = document.getElementById("availmodules");
    var selindex = modSelect.selectedIndex;
	var infoDiv = document.getElementById("availmodinfodiv");
    infoDiv.innerHTML = "<table class='modinfo'><tr><td colspan=2>Module information</td></tr><tr><td width='150px'>Modulename:</td><td>" + modulejsonData.modules[selindex].modulename + "</td></tr><tr><td>Module type:</td><td>" + modulejsonData.modules[selindex].moduletype + "</td></tr><tr><td>Module verion:</td><td>" + modulejsonData.modules[selindex].moduleversion + "</td></tr></table>";
}

function createCase(){
	var value = new String();
	var caseid = document.getElementById('caseid').value;
	var casedescription = document.getElementById('casedesc').value;
	var caseinvestigator = document.getElementById('caseinvestigator').value;
    //linkedModulejsonData = null;
	
	if (caseid != '' && casedescription != '' && caseinvestigator !=""){
	    value = encodeURIComponent('command=newcase&caseid=' + caseid + '&casedescr=' + casedescription + '&caseinvest=' + caseinvestigator);
			$.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, contentType: 'application/x-www-form-urlencoded',
    	   success: function(data){
		     if ( data = "CASE_CREATED"){
		    	infomessage(data);
		    	document.getElementById('caseid').value="";
		    	document.getElementById('casedesc').value="";
		    	document.getElementById('caseinvestigator').value="";
				$("#caseinvestigator_check").html("");
				$("#casedesc_check").html("");
				$("#caseid_check").html("");
		    	newCaseId = caseid;
		        hideNewCase();
		        showNewCaseModule();
		     }
		     else {
		     	infomessage(data);
		     }
			   }
		    });	
	}
}

function checkCaseExists(){
	this.value = sanitizeString(this.value);
	var casevalue = this.value;
	if ( casevalue != "" ){
	    var value = "command=caseexist&caseid=" + casevalue;
		$("#caseid_check").html("<img src='/images/wait.gif' class='checkImage'></img>");
		if (value != ""){
	   		$.ajax({url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, success: function(data){
    		   data = data.replace(/(\r\n|\n|\r)/gm,"");
    		   if ( data == 'CASE_EXISTS'){
    			  $("#caseid_check").html("<img src='/images/nok.png' class='checkImage'></img>");
					  infomessage("CASE_EXISTS");
    		   }
    		   else {
    			  $("#caseid_check").html("<img src='/images/ok.png' class='checkImage'></img>");
   			   }
    		}});
		}
	}
	else {
	   $("#caseid_check").html("<img src='/images/nok.png' class='checkImage'></img>");
	   $("#caseid_check").html('<font size="0.5pt">' + lenght + "/" + maxlenght + '</font>');
	}
}

function checkReopenState(){
	   var value = "command=reopenstate";
	   $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
	      data = data.replace(/(\r\n|\n|\r)/gm,"");

	      var datalength = data.length;
	      var message = data.substr(0, 13);
	      caseid = data.substr(13, datalength);
	      
	      if ( message == "SCHED_REOPEN_") {
	      	 infomessage("SCHED_REOPEN_");
	      }
		 }
	   });
	}    

function cancelReopenCase(){
	hideMessage();
	caseid="";
	cancelReopen();
}

function getCases(){
	   var availcases = document.getElementById("availcases");
	   var value = "command=getcases";
	   $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
	      jsonData = JSON.parse( data );
		  var countCases = 0;
		  var objCaseItem = new Object();
		  for(_obj in jsonData.cases){
		     countCases++;
		  };
		  var caseItemCount = 0;
		  $("#availcases").empty();
		  
		  var newoption= document.createElement('option');
		  newoption.text = "--Select case--";
		  newoption.value = "--Select case--";
		  availcases.add(newoption, caseItemCount);
		  
		  while (caseItemCount < countCases ) {
		     objCaseItem = jsonData.cases[caseItemCount];
					  
			 var newoption= document.createElement('option');
			 newoption.text = objCaseItem.caseid;
			 newoption.value = objCaseItem.caseid;
			 availcases.add(newoption, caseItemCount + 1);
		     caseItemCount++;
	      }
	     }
	   });
}

function getCases2(){
	   var availcases2 = document.getElementById("availcases2");
	   var value = "command=getcases";
	   $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
	      jsonData = JSON.parse( data );
		  var countCases = 0;
		  var objCaseItem = new Object();
		  for(_obj in jsonData.cases){
		     countCases++;
		  };
		  var caseItemCount = 0;
		  $("#availcases2").empty();
		  
		  var newoption= document.createElement('option');
		  newoption.text = "--Select case--";
		  newoption.value = "--Select case--";
		  availcases2.add(newoption, caseItemCount);
		  
		  while (caseItemCount < countCases ) {
		     objCaseItem = jsonData.cases[caseItemCount];
					  
			 var newoption= document.createElement('option');
			 newoption.text = objCaseItem.caseid;
			 newoption.value = objCaseItem.caseid;
			 availcases2.add(newoption, caseItemCount + 1);
		     caseItemCount++;
	      }
	     }
	   });
}

function changeCaseSelection() {
    selection = jQuery('#availcases option:selected').val();
    var attModules = document.getElementById('attmodules');
    linkedModulejsonData = [];
    if ( selection != "--Select case--" ) {
       var value = "command=getlinkedmodules&caseid=" + selection;
       $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, contentType: 'application/x-www-form-urlencoded', success: function(data){
	      data = data.replace(/(\r\n|\n|\r)/gm,"");
          if ( data != "NO_LINKED_MODULES") {
             linkedModulejsonData = JSON.parse( data );
	         var countModules = 0;
	         var objModuleItem = new Object();
	         for(_obj in linkedModulejsonData.modules){
		        countModules++;
	         };
 	         var moduleItemCount = 0;
	         $("#attmodules").empty();	   
	         while (moduleItemCount < countModules ) {
	            objModuleItem = linkedModulejsonData.modules[moduleItemCount];
		        var newoption= document.createElement('option');
		        newoption.text = objModuleItem.workdir;
		        newoption.value = objModuleItem.workdir;
		        attModules.add(newoption, moduleItemCount);
	            moduleItemCount++;
	         }
	      }
	      else {
	   	     $("#attmodules").empty();	
	   	     var newoption= document.createElement('option');
		     newoption.text = "--No modules linked--";
		     newoption.value = "--No modules linked--";
		     attModules.add(newoption, 0);
	      }
        }
      });
   }
   else {
   	  $("#attmodules").empty();	
	  var newoption= document.createElement('option');
      newoption.text = "--No modules linked--";
	  newoption.value = "--No modules linked--";
	  attModules.add(newoption, 0);
   }
}

function pageFullyLoaded(e) {
	//loadMenu();
	resizeContent(); 
}

function isCaseOpen(){
	var value = "command=iscaseopen";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	var datalength = data.length;
	    var message = data.substr(0, 12);
	    caseid = data.substr(12, datalength);
	    if ( message == "CASE_OPENED_") {
		   loadCaseMenu();
	    }
	    else {
	       loadMenu();
	    }
	    
      }
    });
}

function sleep(milliSeconds){
	var startTime = new Date().getTime(); // get the current time
	while (new Date().getTime() < startTime + milliSeconds); // hog cpu
}

function showShutdown() {
    document.getElementById('content_mask').style.visibility='visible';
    document.getElementById('shutdown').style.visibility='visible';
	document.getElementById("shutdownanswer").value = "";
}
 
function showShutdownopen() {
    document.getElementById('content_mask').style.visibility='visible';
    document.getElementById('shutdownopen').style.visibility='visible';
	document.getElementById("shutdownopenanswer").value = "";
}
 
function hideShutdown() {
    document.getElementById('content_mask').style.visibility='hidden';
    document.getElementById('shutdown').style.visibility='hidden';
}

function hideDateTime() {
    document.getElementById('content_mask').style.visibility='hidden';
    document.getElementById('datetime').style.visibility='hidden';
}

function hideShutdownopen() {
    document.getElementById('content_mask').style.visibility='hidden';
    document.getElementById('shutdownopen').style.visibility='hidden';
}

function showNewCase() {
    document.getElementById('content_mask').style.visibility='visible';
    document.getElementById('newcase').style.visibility='visible';
}

function showdateTime() {
    hideMessage();
	document.getElementById('content_mask').style.visibility='visible';
    document.getElementById('datetime').style.visibility='visible';
    getDateTime("0");
}
 
function hideNewCase() {
    document.getElementById('content_mask').style.visibility='hidden';
    document.getElementById('newcase').style.visibility='hidden';
}

function showOpenCase() {
    document.getElementById('content_mask').style.visibility='visible';
    document.getElementById('opencase').style.visibility='visible';
	getCases2();
}
 
function showInitStorage() {
    document.getElementById('btn_initstor').style.visibility='visible';
    document.getElementById('content_mask').style.visibility='visible';
    document.getElementById('initstorage').style.visibility='visible';

    getStorageInfo("0");
    //isFbStorageMounted();
}

function hideInitStorage() {
    document.getElementById('btn_initstor').style.visibility='hidden';
    document.getElementById('content_mask').style.visibility='hidden';
    document.getElementById('initstorage').style.visibility='hidden';
 
 	$("#availdisks").empty();
 	var availdisks = document.getElementById("availdisks");
	var newoption= document.createElement('option');
	newoption.text = "--No disks found--";
	newoption.value = "--No disks found--";
	availdisks.add(newoption, 0);

 	$("#availraid").empty();
   	var availraid = document.getElementById("availraid");
	var newoption= document.createElement('option');
	newoption.text = "--No RAID config--";
	newoption.value = "--No RAID config--";
	availraid.add(newoption, 0);
	
    document.getElementById("storagestatus").innerHTML = "";
	document.getElementById("answerfsinit").value = "";
}

function getStorageInfo(autocheck){
	value="command=getstorageinfo";
	$.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value,  contentType: 'application/x-www-form-urlencoded', success: function(data){
        var storageInfo = new Object();
        var diskInfo = new Object();
        countDisks=0;
        diskCount=0;
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	
    	storageInfo = JSON.parse(data);  
    	for(_obj in storageInfo.storage[0].disks){countDisks++;};

    	$("#availdisks").empty();     	
     	while (diskCount < countDisks ) {
    	   var availdisks = document.getElementById("availdisks");
		   var newoption= document.createElement('option');
		   newoption.text = storageInfo.storage[0].disks[diskCount].disk;
		   newoption.value = storageInfo.storage[0].disks[diskCount].disk;
		   availdisks.add(newoption, (diskCount + 1));
    	   diskCount++;
		}

    	$("#availraid").empty();
      	var availraid = document.getElementById("availraid");
		var newoption= document.createElement('option');
		newoption.text = storageInfo.storage[0].raid[0].storagedev;
		newoption.value = storageInfo.storage[0].raid[0].storagedev;
		availraid.add(newoption, 0); 
    	
        var statusHTML = new String();
 	    if ( storageInfo.storage[0].firestor[0].ismounted == "1" ){
 	   	   statusHTML= "<p>The firestor storage is currently mounted";
 	   	   if ( storageInfo.storage[0].firestor[0].fscorrect == "1"){ 
 	   	      statusHTML += ", initialisation is not needed since the filesystem is (" + storageInfo.storage[0].firestor[0].filesystem + "). ";
 	   	   }
 	   	   else{
 	   	   	  statusHTML += ", initialisation is needed since the filesystem is (" + storageInfo.storage[0].firestor[0].filesystem + "). ";
 	          if ( autocheck == "1"){
 	        	 showInitStorage();
 	        	 document.getElementById('btn_initstor').style.visibility='hidden';
 	          }
 	   	   }
 	   	   if ( storageInfo.storage[0].firestor[0].israid == "1"){ 
 	   	      statusHTML += "<p>The storage is configured in a raid configuration on device " + storageInfo.storage[0].firestor[0].blockdevice + ".</p>";
 	   	   }
 	   	   else{
 	   	   	  statusHTML += "The storage is NOT configured in a raid configuration but resides on " + storageInfo.storage[0].firestor[0].blockdevice + ". ";
              statusHTML += "When two disks are installed and the storage is initialised using this screen this will be corrected.</p>";
 	   	   }
        }
        else{
        	statusHTML= "<p>The firestor storage is currently NOT mounted, this can either mean that the storage has not been initialised or that something went wrong.</p>";
        	if ( autocheck == "1"){
        		showInitStorage();
        		document.getElementById('btn_initstor').style.visibility='hidden';
        	}
        }
          
        document.getElementById("storagestatus").innerHTML = statusHTML;
      }
    });
}

function hideOpenCase() {
    document.getElementById('content_mask').style.visibility='hidden';
    document.getElementById('opencase').style.visibility='hidden';
}

function showNewCaseModule() {
	    document.getElementById('content_mask').style.visibility='visible';
	    document.getElementById('casemodule').style.visibility='visible';
	    getCases();
	    if ( newCaseId != ""){
	        var caseSelector = document.getElementById('availcases');
			$("#availcases").empty();	  
			var newoption = document.createElement('option');
			newoption.text = newCaseId;
			newoption.value = newCaseId;
			caseSelector.add(newoption, 0);
			changeCaseSelection();
	    }
}
	 
function hideNewCaseModule() {
	    document.getElementById('content_mask').style.visibility='hidden';
	    document.getElementById('casemodule').style.visibility='hidden';
}

function showMessage() {
    document.getElementById('message_mask').style.visibility='visible';
    document.getElementById('message').style.visibility='visible';
}
 
function hideMessage() {
    document.getElementById('message_mask').style.visibility='hidden';
    document.getElementById('message').style.visibility='hidden';
}

function getDateTime(message){
	var currentdate = new Date();
    var value = "command=getdatetime";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value,  contentType: 'application/x-www-form-urlencoded', success: function(data){
    	var fbDatetime = new Object();
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	fbDatetime = JSON.parse(data);
    	fbDate=fbDatetime.datetime[0].day + "-" + fbDatetime.datetime[0].month + "-" + fbDatetime.datetime[0].year;
    	fbTime=fbDatetime.datetime[0].hour + ":" + fbDatetime.datetime[0].minute + ":" + fbDatetime.datetime[0].second;
    	document.getElementById('fbcurrentdt').innerHTML = fbDate + " @ " + fbTime;
    	   	
    	fbcurrentdate.setFullYear(fbDatetime.datetime[0].year);
    	fbcurrentdate.setMonth(("0" + (fbDatetime.datetime[0].month-1)).slice(-2));
    	fbcurrentdate.setDate(("0" + fbDatetime.datetime[0].day).slice(-2));
    	fbcurrentdate.setHours(("0" + fbDatetime.datetime[0].hour).slice(-2));
    	fbcurrentdate.setMinutes(("0" + fbDatetime.datetime[0].minute).slice(-2));

    	var datetime = ("0" + currentdate.getDate()).slice(-2) 
        + "-" + ("0" + (currentdate.getMonth()+1)).slice(-2) 
        + "-" + currentdate.getFullYear() + " @ " 
        + ("0" + currentdate.getHours()).slice(-2) 
        + ":" + ("0" + currentdate.getMinutes()).slice(-2) 
        + ":" + ("0" + currentdate.getSeconds()).slice(-2);
        document.getElementById('localcurrentdt').innerHTML = datetime;

        localdt.setFullYear(currentdate.getFullYear());
        localdt.setMonth(("0" + currentdate.getMonth()).slice(-2));
        localdt.setDate(("0" + currentdate.getDate()).slice(-2));
        localdt.setHours(currentdate.getHours());
        localdt.setMinutes(("0" + currentdate.getMinutes()).slice(-2));
        localdt.setSeconds(("0" + currentdate.getSeconds()).slice(-2));  
        currentdate = null;

       if ( message == "1"){
          var diff = (localdt - fbcurrentdate);///(1000*60);
          if ( diff <= -300000 || diff >= 300000){
             infomessage("DATETIME_DISC");
          }
       }
    	
    }
   });
}

function closeNewCaseModule() {
    newCaseId="";
	hideNewCaseModule();
    var sellocation = document.getElementById('modlocation');
    sellocation.selectedIndex = 0;
	$("#attmodules").empty();
	$("#availmodules").empty();
	var infoDiv = document.getElementById("availmodinfodiv");
    infoDiv.innerHTML = "";
}

function closeNewCase(){
	document.getElementById('caseid').value="";
	document.getElementById('casedesc').value="";
	document.getElementById('caseinvestigator').value="";
	$("#caseinvestigator_check").html("");
	$("#casedesc_check").html("");
	$("#caseid_check").html("");
	hideNewCase();
}

function setFbDateTime(){
	var answer = document.getElementById("setdtanswer").value;
	document.getElementById("setdtanswer").value = "";
	if ( answer == "YES"){
       getDateTime("0");
	   
	   var month = new Array();
       month[0] = "January";
	   month[1] = "February";
	   month[2] = "March";
	   month[3] = "April";
	   month[4] = "May";
	   month[5] = "June";
	   month[6] = "July";
	   month[7] = "August";
	   month[8] = "September";
	   month[9] = "October";
	   month[10] = "November";
	   month[11] = "December";
       
       var datetime = ("0" + localdt.getDate()).slice(-2) + "-" + month[localdt.getMonth()]
            + "-" + localdt.getFullYear() + " " + ("0" + localdt.getHours()).slice(-2) 
            + ":" + ("0" + localdt.getMinutes()).slice(-2) + ":" + ("0" + localdt.getSeconds()).slice(-2);

	   value=encodeURIComponent("command=setdatetime&clienttime=" + datetime);
       $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, contentType: 'application/x-www-form-urlencoded', success: function(data){
	      data = data.replace(/(\r\n|\n|\r)/gm,"");
	      hideDateTime();
	      infomessage(data);
          }
       });
    }

}

function linkModule() {
    selection = jQuery('#availmodules option:selected').val();
    modSelect = document.getElementById("availmodules");
    var caseid = jQuery('#availcases option:selected').val();
    var isLinked = false;

    if ( caseid != "--Select case--"){
        var selindex = modSelect.selectedIndex;
        var moduleFileName = modulejsonData.modules[selindex].modulefilename;
        var moduleName = modulejsonData.modules[selindex].modulename;
           
        for (var key in linkedModulejsonData.modules) {
            var obj = linkedModulejsonData.modules[key];
            if (obj.filename == moduleFileName){
            	isLinked = true;
            }
         }
        
        if ( isLinked == true ){
           infomessage("MODULE_ALREADY_LINKED");
        }
        else {
           var value = "command=addmodule&caseid=" + caseid + "&modulefilename=" + moduleFileName + "&workdirname=" + moduleName;
        
           infomessage("LINKING_MODULE");
           var spinner = new Spinner(bigSpinner).spin(target);
           $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, contentType: 'application/x-www-form-urlencoded', success: function(data){
    	      data = data.replace(/(\r\n|\n|\r)/gm,"");
    	      changeCaseSelection();
    	      spinner.stop();
 		      hideMessage();
    	      if ( data != "READY" ){
    	         infomessage(data);
    	      }
    	      else{
    		     infomessage("LINKED_MODULE"); 
    	      }
             }
           });
        }
    }
    else {
    	infomessage("SELECT_CASE");
    }
    
}

function openCase(){
	   selection = jQuery('#availcases2 option:selected').val();
	   caseid=selection;
	   if ( selection != "--Select case--") {
		  infomessage("OPENING_CASE");
          var spinner = new Spinner(bigSpinner).spin(target);
          var value = "command=opencase&caseid=" + selection;
          $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
	         spinner.stop();
	         data = data.replace(/(\r\n|\n|\r)/gm,"");
	         if (data == "CASE_OPENED") {
 	            hideMessage();
 	            hideOpenCase();
	            loadCaseMenu();
	         }
 	         else if (data == "USBMODULELOCATION_NOT_MOUNTED") {
 	            infomessage(data + "_CASEOPEN");
 	         }
 	         else {
 	    	    infomessage(data);
	         }
           }
          });
	   }
	   else {
	   	  infomessage("SELECT_OPENCASE");
	   }
}

function mountModuleDiskCaseOpen(){
       var spinner = new Spinner(bigSpinner).spin(target);
	   var value = "command=mountmoduledisk";
	   $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
		   hideMessage();
		   spinner.stop();
		   data = data.replace(/(\r\n|\n|\r)/gm,"");
		   if ( data == "") {
	    	  openCase();
	      }
	      else {
	   	   hideMessage();
		   spinner.stop();
	       closeCase();
	       hideOpenCase();
	       infomessage(data);
	      }
	   }});
}

function mountModuleDisk(){
	   var spinner = new Spinner(bigSpinner).spin(target);
	  
	   var value = "command=mountmoduledisk";
	   $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
	      spinner.stop();
	      hideMessage();
	      if ( data == "") {
	      	showModulesInLocation();
	      }
	      else {
	       infomessage(data.replace(/(\r\n|\n|\r)/gm,""));
	       var sellocation = document.getElementById('modlocation');
	       sellocation.selectedIndex = 0;
	       resetModuleDialog();
	      }
	   }});
}

function startReopenCase(){
	infomessage("OPENING_CASE");
    var spinner = new Spinner(bigSpinner).spin(target);
    var value = "command=reopencase";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
	   spinner.stop();
	   data = data.replace(/(\r\n|\n|\r)/gm,"");
	   if (data == "CASE_OPENED") {
 	      hideMessage();
 	      hideOpenCase();
	      loadCaseMenu();
	   }
 	   else if (data == "USBMODULELOCATION_NOT_MOUNTED") {
 	      infomessage(data + "_CASEOPEN");
 	   }
 	   else {
 	      infomessage(data);
	   }
     }
    });
}

function closeCase(){
    var value = "command=closecase";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	if (data == "CASE_CLOSED") {
    		hideOpenCase();
    		loadMenu();
            caseid="";
    	}
      }
   });
}

function cancelReopen(){
    var value = "command=cancelreopen";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	if (data == "REOPEN_CANCELED") {
    		hideMessage();
    		loadMenu();
            caseid="";
            infomessage("REOPEN_CANCELED");
    	}
      }
   });
}

function closeCaseReopen(){
    var value = "command=closereopen";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	if (data == "CASE_CLOSED") {
            caseid="";
    	}
      }
   });
}

function shutdownfb(){
	infomessage("SHUTDOWN_SENT");
	var spinner = new Spinner(bigSpinner).spin(target);
    var value = "command=shutdown";
    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, async: false, contentType: 'application/x-www-form-urlencoded', success: function(data){
    	data = data.replace(/(\r\n|\n|\r)/gm,"");
    	spinner.stop();
    	if (data == "SHUTDOWN_RECEIVED") {
    		infomessage(data);
            caseid="";
    	}
      }
   });
}

function shutdownopen(){
	var answer = document.getElementById("shutdownopenanswer").value;
	document.getElementById("shutdownopenanswer").value = "";
	if ( answer == "YES"){
		closingCaseForReopen();
		shutdownfb();
	}
}

function closingCase(){
	hideShutdown();
	infomessage("CLOSING_CASE");
	var spinner = new Spinner(bigSpinner).spin(target);
	closeCase();
	spinner.stop();
	hideMessage();
}

function closingCaseForReopen(){
	hideShutdownopen();
	infomessage("CLOSING_CASE_REOPEN");
	var spinner = new Spinner(bigSpinner).spin(target);
	closeCaseReopen();
	spinner.stop();
	hideMessage();
}

function hideNOUSBMessage() {
   hideMessage();
   closeCase();
}

function hideOpenCaseMessage(){
	   hideMessage();
	   hideOpenCase();
	   closeCase();	
}

function resetModuleDialog(){
  	var availmodules = document.getElementById("availmodules");
	$("#availmodules").empty();
	var newoption= document.createElement('option');
	newoption.text = "--Select module location--";
	newoption.value = "--Select module location--";
	availmodules.add(newoption, 0);
	var infoDiv = document.getElementById("availmodinfodiv");
	infoDiv.innerHTML = "";	
}

function hideDateTimeMessage(){
	hideMessage();
    //getDateTime("0");
	value=encodeURIComponent("command=setdtcancel&clienttime=" + localdt);
	$.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value, contentType: 'application/x-www-form-urlencoded', success: function(data){
		data = data.replace(/(\r\n|\n|\r)/gm,"");
		infomessage(data);
	}});
}

function shutdown(){
	var answer = document.getElementById("shutdownanswer").value;
	document.getElementById("shutdownanswer").value = "";
	if ( answer == "YES"){
		closingCase();
		shutdownfb();
	}
}

function initStorage(){
	var answer = document.getElementById("answerfsinit").value;
	if ( answer == "YES" ){
		infomessage("INIT_STORAGE");
		var spinner = new Spinner(bigSpinner).spin(target);
	    value="command=initstorage";
	    $.ajax({ url: "/cgi-bin/ajax.cgi", type: 'POST', data: value,  contentType: 'application/x-www-form-urlencoded', success: function(data){
    	    data = data.replace(/(\r\n|\n|\r)/gm,"");
    	    spinner.stop();
    	    hideMessage();
    	    hideInitStorage();
    	    infomessage(data);
            }
        });
    }
}

function infomessage(data){
	   switch(data) {
	     case "INIT_STORAGE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Initialising Storage</H2><p>Please wait!</p>';
            break;
	     case "REOPEN_CANCELED":
		    showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Case reopen canceled</H2>';
			setTimeout(hideMessage, 1000);
			break;
	     case "CASE_CREATED":
	    	showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Case created</H2>';
			setTimeout(hideMessage, 1000);
			break;
	     case "CASE_CLOSED":
		    showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Temporary case data succesfully removed</H2>';
			setTimeout(hideMessage, 1000);
			break;
	     case "DATETIME_UPDATED":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Date and Time succefully updated on the FIREBrick</H2>';
			setTimeout(hideMessage, 1000);
			break;    	 
	     case "CLOSING_CASE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Cleaning Up</H2>';
			break;
	     case "CLOSING_CASE_REOPEN":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Cleaning Up and setting op case to reopen a next startup</H2>';
			break;
	     case "SHUTDOWN_SENT":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Sent shutdown to FIREBrick</H2>';
			break;
	     case "SHUTDOWN_RECEIVED":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>FIREBrick received shutdown signal</H2><br>Be sure to unplug any USB-sticks and other devices when the FIREBrick is powered off';
			break;	    	 
	     case "CLOSING_CASE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Cleaning Up and prepare for reopen</H2>';
			break;
	     case "OPENING_CASE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Starting Case</H2>';
			break;	    	 
	     case "ERROR_CLOSING_CASE":
			showMessage();
		    var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error cleaning up</H2><br><br>Please reboot the FIREBrick to try to resolve the problem, verify the system logs to find the problem.';
		    break;
	     case "LOCALIZATION_ERROR":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Localization error</H2><br><br>Please reboot the FIREBrick to try to resolve the problem<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "CHECK_INPUT":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Input error</H2><br><br>A function did not receive the exptected arguments.<br>Try to reboot the FIREBrick to resolve the problem and check the system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "FIRESTOR_NOT_MOUNTED":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Firestor not mounted</H2><br><br>The firestor storage is not mounted. This could mean that it is not initialised or something else is wrong.<br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_LOG_DIRECTORY":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No log destination</H2><br><br>The log destination is not available.<br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';	  
		    break;
	     case "NO_WRITE_ACCESS":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No write access!</H2><br><br>The system has no write acces to the firestor storage. This could mean that it is not initialised or something else is wrong.<br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_SYSTEM_DIRECTORY":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No system directory</H2><br><br>No system directory found on the firestor<br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_SYSTEM_CONFIGFILE":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No system configuration file found</H2><br><br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_UPDATING_CONFIGURATION":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error updating configuration file</H2><br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "CFG_NOT_EXIST":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Configuration file does not exist</H2><br>Please reboot the FIREBrick to try to resolve the problem if that fails try to initialise the storage.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_CASENR_RECEIVED":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No casebumber received!</H2><br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "CASE_EXISTS":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>The case already exists</H2><br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_contentLenght":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The contentLenght server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_contentType":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The contentType server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_httpHost":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The httpHost server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_httpReferrer":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The httpReferrer server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_httpUserAgent":
	 	    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The httpUserAgent server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	    case "NO_VAR_remoteAddress":
	 	    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The remoteAddress server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_requestMethod":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The requestMethod server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_requestUri":
	 	    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The requestUri server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_scriptFileName":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The scrpitFileName server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_varPair":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The varPair server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_VAR_QUERYSTRING":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error reading variable</H2><br>The querystring server-variable could not be read<br>Please reboot the FIREBrick to try to resolve the problem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_NO_UNUSED_UID":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error allocating UserID</H2><br>No unused UserID could be allocated<br>Please reboot the FIREBrick to try to resolve the problem. IF that does not work initialise the firestor storage<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_ALLOCATING_UID":
	 	    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error allocating UserID</H2><br>No unused UserID could be allocated<br>Please reboot the FIREBrick to try to resolve the problem. IF that does not work initialise the firestor storage<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_NO_UNUSED_GID":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error allocating GroupID</H2><br>No unused GroupID could be allocated<br>Please reboot the FIREBrick to try to resolve the problem. IF that does not work initialise the firestor storage<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "ERROR_ALLOCATING_GID":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error allocating GroupID</H2><br>No unused GroupID could be allocated<br>Please reboot the FIREBrick to try to resolve the problem. IF that does not work initialise the firestor storage<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_NO_UNUSED_HTTPPORT":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error allocating httpPort</H2><br>No unused httpPort could be allocated<br>Please reboot the FIREBrick to try to resolve the problem. IF that does not work initialise the firestor storage<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_ALLOCATING_HTTPPORT":
	 	    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error allocating httpPort</H2><br>No unused httpPort could be allocated<br>Please reboot the FIREBrick to try to resolve the problem. IF that does not work initialise the firestor storage<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_CREATING_GROUP":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error creating group</H2><br>Error creating group<br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "ERROR_CREATING_USER":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error creating user</H2><br>Error creating user<br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "NO_ACCOUNT_SECTION_FOUND":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No account section found</H2><br>The configuration file of this case does not contain an account section.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "CASECONFIG_NOT_FOUND":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error case configration file not found</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "REFERER_NO_MATCH":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error referrer does not match</H2><br>The referrer does not match. Possible site cross scripting<br>Please reboot the FIREBrick to try to resolve the problem and review system logs and review linked modules<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "REFERER_NOT_SET":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error referrer not set</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "NOT_POST_BUT_":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error data method</H2><br>The used datamethod is GET not POST!<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "ERROR_MOUNTING_PARTITION":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error mounting</H2><br>Disk or module could not be mounted<br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "ERROR_CREATING_MOUNTPOINT":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error creating mountpoint</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "ERROR_MOUNTING_MODULE":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error mounting</H2><br>Disk or module could not be mounted<br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "ERROR_CREATING_DEVICENODE":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error creating devicenode</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "NO_USB_FAT32_PARTITION_DETECTED":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error module disk filesystem</H2><br>The module disk does not have a FAT32 filesystem.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "NO_USBDISK_PLUGGEDIN":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No USB storage plugged</H2><br>USB storage seems no to be plugged in.<br><p>Please reboot the FIREBrick to try to resolve the problem and review system logs</p><br><input type="button" value="Close" onclick="hideNOUSBMessage();"/>';
	        break;     
	     case "BAD_INPUT_DATA":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Bad function inputdata</H2><br>A function received bad input data.<br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "ERROR_CREATING_DIRECTORY":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error creating directory</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "ERROR_CHANGING_OWNERSHIP":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error changing ownership</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "ERROR_DIRECTORY_NOT_EXIST":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error directory doe not exist</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;     
	     case "MODULE_HASH_DOES_NOT_MATCH":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Module hash does not Match!!</H2><br>The module linked to the case seems to be changed. The hash does not match!!<br>Please reboot the FIREBrick to try to resolve the problem and review system logs and review modules.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "ERROR_UNMOUNTING":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error umounting</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;     
	     case "NO_MODULE_SECTION_FOUND":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No module section found</H2><br>The configuration file of this case does not contain a module section.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break; 
	     case "ERROR_BINDING":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error binding port</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break; 
	     case "ERROR_CREATING_UNIONFS":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error creating unionfs</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break; 
	     case "ERROR_STARTING_WEBSERVER":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error staring webserver</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break; 
	     case "HASH_VERIFICATION_FAILED":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Verification of hash file failed</H2><br>Unable to verify and decrypt hash file. Either file has changed of signature is not trusted. Review system logs.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break; 
	     case "CASE_CONFIG_NOT_FOUND":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Case configuration file not found!</H2><br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break; 
	     case "ERROR_TERMINATING_PROCESSES":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error terminating processes</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_DELETING_USER":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error deleting user</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_DELETING_GROUP":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error deleting group</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_DELETING_DIRECTORY":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error deleting directory</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_UMOUNTING":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error umounting storage</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_MOVING_FILE":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error moving file</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "ERROR_CANNOT_REOPEN":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Error unable to reopen case</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "USBMODULELOCATION_NOT_MOUNTED":
		    resetModuleDialog();
			showMessage();
		    var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>USB Module storage not mounted</H2><br>Click on the button [Scan for USB-storage] and then plug in the module USB-storage.<br><br><input type="button" value="Scan for USB-storage" onclick="mountModuleDisk();"/>';
		    break;
	     case "USBMODULELOCATION_NOT_MOUNTED_CASEOPEN":
	    	resetModuleDialog();
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>USB Module storage not mounted</H2><br>Click on the button [Scan for USB-storage] and then plug in the module USB-storage.<br><br><input type="button" value="Scan for USB-storage" onclick="mountModuleDiskCaseOpen();"/>';
	        break;
	     case "INTERNALMODULELOCATION_NOT_AVAILABLE":
		    resetModuleDialog();
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Internal Module storage not available</H2><br>This can either mean that there are no modules loaded on the internal storage, or something went wrong. If modules are loaded on the internal storage then please reboot the FIREBrick to try to resolve the problem and review system logs.<br><br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;
	     case "UNKNOWN_MODULELOCATION_INT":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>Unknown module location</H2><br>Please reboot the FIREBrick to try to resolve the problem and review system logs.<br><input type="button" value="Close" onclick="hideMessage();"/>';
	        break;
	     case "NO_LINKED_MODULES":
		    showMessage();
	    	var messageDiv = document.getElementById("message");
		    messageDiv.innerHTML = '<H2>No linked modules</H2><br>The case doen not have linked modules.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
	        break;
	     case "MODULE_NOT_FOUND":
			showMessage();
		    var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Module not found</H2><br>The linked module cannot be found.<br><input type="button" value="Close" onclick="hideOpenCaseMessage();"/>';
		    break;
	     case "SELECT_CASE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>No case selected!</H2><br>To link a module to a case a case must be selected.<br><input type="button" value="Close" onclick="hideMessage();"/>';
			break;
	     case "SELECT_OPENCASE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>No case selected!</H2><br><p>To open a case a case must be selected.</p><br><input type="button" value="Close" onclick="hideMessage();"/>';
			break;			
	     case "LINKING_MODULE":			
	        showMessage();
	    	var messageDiv = document.getElementById("message");
	    	messageDiv.innerHTML = '<H2>Linking module to case...</H2>';
	    	break;
	     case "LINKED_MODULE":
		    showMessage();	
	    	var messageDiv = document.getElementById("message");
  		    messageDiv.innerHTML = '<H2>Module successfully linked to case</H2>';
			setTimeout(hideMessage, 1000);
			break;
	     case "NO_OPENED_CASE":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>No case opened!</H2><br><br><input type="button" value="Close" onclick="hideMessage();"/>';
			break;
	     case "MODULE_ALREADY_LINKED":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>This module already linked!</H2><br><p>This module already seems to be linked to this case. A module may only be linked once on the same case.</p><br><input type="button" value="Close" onclick="hideMessage();"/>';
			break;
	     case "DATETIME_DISC":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Date/Time on FIREBrick and Client to not match!</H2><br><p>The Date/Time difference between the FIREBrick and you Client are of by more than 5 minutes. Verify the date and time on your workstation and update the date and time on the FIREBrick.</p><br><input type="button" value="Close" onclick="hideDateTimeMessage();"/><input type="button" value="Time Settings" onclick="javascript:showdateTime();"/>';
			break;
	     case "UNABLE_TO_UMNOUNT_FIRESTOR":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to unmount firestor!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "UNABLE_TO_REMOVE_RAID":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to remove RAID!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "UNABLE_TO_STOP_RAID":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to stop RAID!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "UNABLE_CREATING_RAIDCFG":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to create RAID configuration!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "SIZE_IS_DIFFERENT":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Disk size for RAID disks is not the same!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "ERROR_MOUNTING_FIRESTOR":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to unmount firestor!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "UNABLE_ERASING_BOOTRECORD":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to erase bootrecord!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "UNABLE_CREATING_PARTITION":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to create partition!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "UNABLE_CREATING_FSSTRUCTURES":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Unable to create filesystem strucutures!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "FIRESTOR_MOUNTED":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Firestor mounted</H2>';
			setTimeout(hideMessage, 1000);
			break;
	     case "NO_STORAGEDEVICES_AVAIL":
			showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>No storage devices available!</H2><br><p>Reboot the firebrick to resolve the problem. If the problem persists check the system logfiles.</p>';
			break;
	     case "SCHED_REOPEN_":
		    showMessage();
			var messageDiv = document.getElementById("message");
			messageDiv.innerHTML = '<H2>Case ' + caseid + ' is selected to be reopend.</H2><p>Do you wish to reopen this case?</p><br><input type="button" value="No" onclick="cancelReopenCase();"/> <input type="button" value="Yes" onclick="startReopenCase();"/>'; 
	    	break;
	  }
}
