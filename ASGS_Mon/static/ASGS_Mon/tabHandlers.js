/*****
 * Various utility functions for tab javascript routines
 * 
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

function updateMsg(val)
{
	var ctrl = $('#' + val);
	
	ctrl.text('Update successful.');
	
	ctrl.fadeIn(2000);
	ctrl.fadeOut(1000);
}
		
function initConfigTabList()
{
	// get the list and render the html
	d3.json("dataReq/?type=config_list", function(error, configList) 
	{
		// init the output
		var output = '<ul>';
		
		// go through all listings
		configList.forEach(function(info, i)
		{
			// tack on each entry
			output += '<li>' + info.instance_name + ' with ID ' + info.instance_id + ', started on: ' + info.start_ts + '. <a href="javascript:getConfigDetails(' + info.instance_id + ', \'asgs\')">View ASGS</a>&nbsp; or &nbsp;<a href="javascript:getConfigDetails(' + info.instance_id + ', \'adcirc\')">View ADCIRC</a></li><div style="display:none; border:1px solid black; margin-left: 10px; margin-top: 5px; margin-right: 5px;" id="configdetail_' + info.instance_id + '"></div>';
		});
		
		// finish off the list
		output += '</ul>';
		
		// output the result
		$("#configTabList").html(output);
	});
}

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
			// storage for the target data
			var theData = null;
			
			// get the type of data to display
			if(type == "asgs")
				data = configDetail.asgs_config
			else
				data = configDetail.adcirc_config
									
			// render the data
			$('#configdetail_' + id).html(data);
			$('#configdetail_' + id).show(1500);
		});
	}
}
