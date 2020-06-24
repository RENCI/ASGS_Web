/*****
 * Various utility functions for tab javascript routines
 * 
 */

/**
 * Populates the Job submit tab area
 * 
 * @param val
 * @returns
 */
function loadJobSubmit(val)
{
	$("#selectedCluster").hide(100);

    rndInUse = Math.floor(Math.random() * 100) + 25;
    rndAvail = Math.floor(Math.random() * 100) + 25;
    
    $('#clusterVal').text("Current " + val + " cluster utilization. " + (rndAvail + rndInUse) + " total nodes.");

    elInUse = '<div style="width: ' + (rndInUse * 4) + 'px; margin-bottom: 5px; margin-left: 5px;">' + rndInUse + ' nodes in use</div>'
    elAvail = '<div style="width: ' + (rndAvail * 4) + 'px; margin-bottom: 5px; margin-left: 5px;">' + rndAvail + ' nodes available</div>';
	
	$('#chartID').html(elInUse + elAvail);
	
	if (val !== "-1")
	{
    	$("#selectedCluster").show(1000);
    	var audio = document.getElementById("audioExpand");
        audio.play();
	}
    else 
    {
    	$("#selectedCluster").hide(1000);
    	var audio = document.getElementById("audioCollapse");
        audio.play();
    }
}	

/**
 * Populates the Site administration tab area
 * 
 * @param val
 * @returns
 */
function loadUser(val)
{
	$("#selectedUserAdmin").hide(100);
	
	var theDate = new Date().toLocaleString();

    $('#userVal').html('<span class="userViewtext">User name: ' + val + '</span><br><span class="userViewtext">Last login: ' + theDate + '</span><br><span class="userViewtext">Role: User');

	if (val !== "-1")
	{
    	$("#selectedUserAdmin").show(1000);
    	var audio = document.getElementById("audioExpand");
        audio.play();
	}
    else 
    {
    	$("#selectedUserAdmin").hide(1000);		    
		var audio = document.getElementById("audioCollapse");
    	audio.play();
    }
}

/**
 * handles data update alert
 *  
 * @param val
 * @returns
 */
function updateMsg(val)
{
	var ctrl = $('#' + val);
	
	ctrl.text('Update successful.');
	
	ctrl.fadeIn(2000);
	ctrl.fadeOut(1000);
}
	
/**
 * Populates the Run configurations tab
 * 
 * @returns
 */
function initConfigTabList()
{
	// get the list and render the html
	d3.json("dataReq?type=config_list", function(error, configList) 
	{
		// if we got good data put it away
		if (error == null && configList.length != 0 && configList != 'None') 
		{ 
			// init the output
			var output = '';
			
			// go through all listings
			configList.forEach(function(info, i)
			{
				// tack on each entry
				output += '<span class="input-group-text" style="margin-top: -3px">' + info.instance_name + '&nbsp;(ID: ' + info.id + ')&nbsp;<a href="javascript:getConfigDetails(' + info.id + ', \'asgs\')">View details</a></span><div style="display:none; border:1px solid black; margin-top: 5px; margin-bottom: 1px" id="configdetail_' + info.id + '"></div><br>';
			});
			
			// output the result
			$("#configTabList").html(output);
		}
	});
}

/**
 * Calls the database to get the run configuration data
 * 
 * @param id
 * @param type
 * @returns
 */
function getConfigDetails(id, type)
{
	// if anything is visible hide it
	if($('#configdetail_' + id).is(':visible'))
	{
		$('#configdetail_' + id).hide(1000);
	}
	// else render the selection
	else 
	{
		// get the render the configuration params
		d3.json("dataReq?type=config_items&param=" + id, function(error, configitems) 
		{	
			// init the return
			var retVal = '';
			
			if(error != null)
				retVal = '<span style="color:red">Error retrieving information.</span>';
			else
			{
				// get the type of data to display
				if(configitems == undefined)
					retVal = '<span style="color:red">&nbsp;&nbsp;Error retrieving information.&nbsp;&nbsp;</span>';
				else if(configitems == 'None')
					retVal = '<span style="color:red">&nbsp;&nbsp;Sorry, no configuration parameters found for this instance.&nbsp;&nbsp;</span>';
				else
				{
					retVal += '<span style="margin-left: 3px">Name : Value</span><br><span style="margin-left: 3px">--------------------</span>';
					
					configitems.forEach(function(info, i){
						retVal += '<br><span style="margin-left: 3px">' + info.key + ' : ' + info.value + '</span>';
					});
				}
			}
			
			// render the data
			$('#configdetail_' + id).html(retVal);
			$('#configdetail_' + id).show(500);
		});
	}
}

/**
 * gets the date in a nice format
 * 
 * @param date
 * @returns
 */
function formatLocalAMPM(date) 
{
	// get the current hours and minutes
	var theHour = date.getHours();
	var minute = date.getMinutes();
	
	// determine AM/PM
	var ampm = theHour >= 12 ? 'pm' : 'am';
	  
	// format the hours
	hour = theHour % 12;
	hour = (hour % 12) ? hour : 12;	  
	  
	// compile the formatted local time
	var lclTime = hour + ':' + ('0' + minute).slice(-2) + ' ' + ampm;
	  
	// get the number of hours off UTC time
	var timezone =  date.getTimezoneOffset() / 60;
		
	// get the UTC hour
	hour = (theHour + timezone) % 24;
	
	// compile the formatted utc time
	var utcTime = ('0' + hour).slice(-2) + ':' + ('0' + minute).slice(-2) + 'z';
			
	// return to the caller
	return 'Local time: ' + lclTime + ', UTC time: ' + utcTime;	
}

/**
 * get the current time, formatted.
 * 
 * @returns
 */
function currentTime()
{
	// get the current date
	date = new Date();

	// get the current hours and minutes
	var theHour = date.getHours();
	var minute = date.getMinutes();
	var second = date.getSeconds();
	
	// determine AM/PM
	var ampm = theHour >= 12 ? 'pm' : 'am';
	  
	// format the hours
	hour = theHour % 12;
	hour = (hour % 12) ? hour : 12;	  
	  
	// compile the formatted local time
	var lclTime = hour + ':' + ('0' + minute).slice(-2) + ':' + ('0' + second).slice(-2) + ' ' + ampm;

	// return to the caller
	return lclTime;
}

/** 
 * formats the time in NCEP format
 * 
 */
function formatNCEPTime(date)
{
	// get the number of hours off UTC time
	var timezone =  date.getTimezoneOffset() / 60;

	// get the hour
	var hour = (date.getHours() + timezone) % 24;

	// format the time into the NCEP 
	var strTime = d.getUTCFullYear() + '/' + ('0' + (d.getUTCMonth() + 1)).slice(-2) + '/' + ('0' + d.getUTCDate()).slice(-2) + ((hour >= 18) ? ' 18z' : ((hour >= 12) ? ' 12z' : ((hour >= 6) ? ' 06z' : ' 00z')));
	
	// return to the caller
	return 'Current NCEP cycle: ' + strTime;
}

/**
 * formats the current time for a DB time stamp
 * @param date
 * @returns
 */
function formatDateTime(date)
{
	// get the current hours and minutes
	var theHour = date.getHours();
	var minute = date.getMinutes();
	var second = date.getSeconds();
		  
	// get the number of hours off UTC time
	var timezone =  date.getTimezoneOffset() / 60;
		
	// get the UTC hour
	hour = (theHour + timezone) % 24;

	// compile the formatted local time
	var UTCDateTime = date.getUTCFullYear() + '/' + ('0' + (date.getUTCMonth() + 1)).slice(-2) + '/' + ('0' + date.getUTCDate()).slice(-2) + ' ' + hour + ':' + ('0' + minute).slice(-2) + ':' + ('0' + second).slice(-2);

	// return to the caller
	return UTCDateTime;
}

/**
 * sets the scroll position and window size for the message area
 * @returns
 */
function scrollToBottom() 
{	
//	// get the current height of the area to put the messages
//	var newHeight = (($('#cardBody')[0].clientHeight - 210) > 500) ? 500 : $('#cardBody')[0].clientHeight - 210;
//
//	// set the message area height
//	$('#chatMsgArea').height(newHeight);
//	
	// if auto scroll is checked force it to the bottom
	if(!$('#chatScrollLock').is(":checked"))
		$('#chatMsgArea').scrollTop($('#chatMsgArea')[0].scrollHeight);
}

/**
 * persists the message in the database
 * 
 * @returns
 */
function sendChatMessage()
{
	// is there anything to send
	if($('#sendChatText').val() != '')
	{
		// get the message
		var msg = $('#sendChatText').val();
		
		// clear the message text box to make ready for the next
		$('#sendChatText').val('');				
		
		// save the message
        d3.json("dataReq?type=insert_chatmsg&username=" + username + "&msg=" + msg, function(error)
		{		
			// if we got an error
			if (error) 
				alert('There was an error sending the chat message!'); 
		});
	}
}

/**
 * shows the chat message in the chat message area
 * 
 * @returns
 */
function addChatMessage(msg)
{	
	// add the message
	$('<div class="chatMsg">' + msg + '</div>').appendTo("#chatMsgArea");
}

/**
 * sends the user preferences to the database
 * 
 * @returns
 */
function sendUserPrefs()
{
	// get the preferred site
	var pref_site = $("#pref_site").val();
	
	// declare space for the selected site filters
	var filter_site = [];

	// get all the selected values into an array
    $.each($("#filter_site option:selected"), function() {            
    	filter_site.push($(this).val());
    });	        
	
	// save the message
    d3.json("dataReq?type=update_user_pref&username=" + username + "&pref_site=" + pref_site.toString() + "&filter_site=" + filter_site.toString(), function(error)
	{		
    	$("#prefsSaveMsg").removeClass();
    	
    	// display the pass/fail message
		if (error)
		{
			$("#prefsSaveMsg").text('There was a problem saving your preferences.');
			$("#prefsSaveMsg").addClass("error");
		}
		else
		{
			$("#prefsSaveMsg").text('Preferences saved.');
			$("#prefsSaveMsg").addClass("pass");
		}

		// show/hide the message
		$("#prefsSaveMsg").show(500);
		$("#prefsSaveMsg").hide(3000);
	});
}

/**
 * gets the user preferences from the database
 * 
 * @returns
 */
function getUserPrefs()
{
	// save the message
    d3.json("dataReq?type=user_pref&username=" + username, function(error, prefs)
	{		
		// if we got an error
		if (error) 
			alert('There was an error getting your preferences!');
		else
		{
			// put away the home site pref on the selection tab	
			$("#pref_site > [value='" + prefs.home_site + "']").attr("selected", "true");
			
			// put away the additional filter site prefs on the selection tab
			$("#filter_site").val(prefs.filter_site);
			
			// merge the primary and additional sites
			prefs.filter_site.push(prefs.home_site);
			
			// save the filters
			$("#siteFilter").val(prefs.filter_site);
			
			// refresh all the filter controls
			$('#siteFilter').selectpicker('refresh');
			$('#pref_site').selectpicker('refresh');
			$('#filter_site').selectpicker('refresh');
		}
	});
}