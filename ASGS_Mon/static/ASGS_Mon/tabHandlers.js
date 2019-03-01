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
	d3.json("dataReq/?type=config_list", function(error, configList) 
	{
		// init the output
		var output = '';
		
		// go through all listings
		configList.forEach(function(info, i)
		{
			// tack on each entry
			output += '<span class="input-group-text">' + info.instance_name + ' - Started on: ' + info.start_ts + '. <a href="javascript:getConfigDetails(' + info.instance_id + ', \'asgs\')">View ASGS</a>&nbsp; or &nbsp;<a href="javascript:getConfigDetails(' + info.instance_id + ', \'adcirc\')">View ADCIRC</a></span><div style="display:none; border:1px solid black; margin-top: 5px; margin-bottom: 5px" id="configdetail_' + info.instance_id + '"></div><br>';
		});
		
		// output the result
		$("#configTabList").html(output);
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
		d3.json("dataReq/?type=config_detail&param=" + id, function(error, configDetail) 
		{	
			// init the return
			var retVal = '';
			
			if(error != null)
				retVal = '<span style="color:red">Error retrieving information.</span>';
			else
			{
				// get the type of data to display
				if(configDetail == undefined)
					retVal = '<span style="color:red">Error retrieving information.</span>';
				else if(type == "asgs")
					retVal = configDetail.asgs_config;
				else if(type == "adcirc")
					retVal = configDetail.adcirc_config;
				else
					retVal = '<span style="color:red">Error retrieving information.</span>';
			}
			
			// render the data
			$('#configdetail_' + id).html(retVal);
			$('#configdetail_' + id).show(1500);
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
	var hour = date.getHours();
	var minute = date.getMinutes();
	
	// determine AM/PM
	var ampm = hour >= 12 ? 'pm' : 'am';
	  
	// format the hours
	hour = hour % 12;
	hour = (hour % 12) ? hour : 12;	  
	  
	// compile the formatted time
	var strTime = hour + ':' + ('0' + minute).slice(-2) + ' ' + ampm;
	  
	// return to the caller
	return strTime;
}

/** 
 * formats the time in NCEP format
 * 
 */
function formatNCEPTime(date)
{
	// get the hour
	var hour = date.getHours();

	// format the time into the NCEP 
	var strTime = d.getUTCFullYear() + '/' + ('0' + (d.getUTCMonth() + 1)).slice(-2) + '/' + ('0' + d.getUTCDate()).slice(-2) + ((hour >= 18) ? ' 18z' : ((hour >= 12) ? ' 12z' : ((hour >= 6) ? ' 06z' : ' 00z')));
	
	// return to the caller
	return strTime;
}
