/*****
 * Renders all site/instance elements
 * 
 * @returns nothing. It renders the tab contents or it doesn't.
 */

// set the instance message status type ids
var _CONST_INSTANCE_INIT_MSG_TYPE = 0;
var _CONST_INSTANCE_RUNN_MSG_TYPE = 1;
var _CONST_INSTANCE_PEND_MSG_TYPE = 2;
var _CONST_INSTANCE_FAIL_MSG_TYPE = 3;
var _CONST_INSTANCE_WARN_MSG_TYPE = 4;
var _CONST_INSTANCE_IDLE_MSG_TYPE = 5;
var _CONST_INSTANCE_CMPL_MSG_TYPE = 6;
var _CONST_INSTANCE_NONE_MSG_TYPE = 7;
var _CONST_INSTANCE_WAIT_MSG_TYPE = 8;
var _CONST_INSTANCE_EXIT_MSG_TYPE = 9;
var _CONST_INSTANCE_STALLED_MSG_TYPE = 10;

//set the event group state type ids
var _CONST_GROUP_INIT_MSG_TYPE = 0;
var _CONST_GROUP_RUNN_MSG_TYPE = 1;
var _CONST_GROUP_PEND_MSG_TYPE = 2;
var _CONST_GROUP_FAIL_MSG_TYPE = 3;
var _CONST_GROUP_WARN_MSG_TYPE = 4;
var _CONST_GROUP_IDLE_MSG_TYPE = 5;
var _CONST_GROUP_CMPL_MSG_TYPE = 6;
var _CONST_GROUP_NONE_MSG_TYPE = 7;
var _CONST_GROUP_WAIT_MSG_TYPE = 8;
var _CONST_GROUP_EXIT_MSG_TYPE = 9;
var _CONST_GROUP_STALLED_MSG_TYPE = 10;

var latestData;

/**
 * Renders the site instances and populates them with data from the database
 * 
 * @param siteInstance
 * @returns
 */
function renderMonitorTab(siteInstance)
{
	// Microsoft browsers do not support EventSource
 	if(EventSource !== undefined && typeof(EventSource) !== "undefined") 
 	{
	 	// define the event endpoint
 		var eSource = new EventSource("dataReq/?type=wellness");
	
 		// detect message receipt to a event load
 		eSource.onmessage = function(event) 
 		{		 	 
			// get the value of the view all since filter
			var viewActiveFlag = $('#viewActive').is(":checked");
			
			// get the since date
			var sinceDate = $('#sinceDate').val(); //($('#sinceDate').val() == '') ? 'NULL' : $('#sinceDate').val();
			
			// get the value of the view all since filter
			var viewInactiveFlag = -1;
			
			// get the checked radio button
			if($('#viewInactive').is(":checked"))
			{
				$("input[data-val]").each(function () 
				{
					if($(this).is(":checked"))
					{
						viewInactiveFlag = $(this).data('val');
					}
				});
			}
			
			// get the selected sites
	        var sites = [];
	        $.each($("#siteFilter option:selected"), function(){            
	        	sites.push($(this).val());
	        });	        

			// create/init the shells for all the site instances
			d3.json("dataReq/?type=init" + "&viewActiveFlag=" + viewActiveFlag + "&viewInactiveFlag=" + viewInactiveFlag + "&sinceDate=" + sinceDate, function(error, initData)
			{				
				// erase all the site instances on error or no data
				if (error || initData.length == 0 || initData == 'None') 
				{
					d3.selectAll(".siteInstanceView").remove();
					
					$("#filterMsg").show(1000);
					
					return;
				}
				else
					$("#filterMsg").hide(0);
					
				// save this data for the event message rendering later
				latestData = initData;
						        		
				// get the current date
				d = new Date()
				
				// get the current hour
				var hour = d.getUTCHours();
							
				// update the current NCEP cycle number
				$("#NCEP_cycle").text('Current NCEP cycle: ' + d.getUTCFullYear() + ('0' + (d.getUTCMonth() + 1)).slice(-2) + ('0' + d.getUTCDate()).slice(-2) + ((hour >= 18) ? '18' : ((hour >= 12) ? '12' : ((hour >= 6) ? '06' : '00'))));
				
				// get the current rendered items
				var curRendered = d3.selectAll(".siteInstanceView").selectAll("svg");

				// do we have a valid site instance already loaded
				if(Array.isArray(curRendered))
				{		
					// init 2 arrays for instance ids
					var a = [];
					var b = [];
					
					// save the data instance ids
					for(i=0; i<initData.length; i++)
						a.push("_" + initData[i].instance_id + '_' + initData[i].advisory_number);
					
					// save the current rendered ids
					for(j=0; j<curRendered.length; j++)
						b.push(curRendered[j].parentNode.id);					
					
					// if they are different remove all rendered 
					if($.merge($(a).not(b).get(), $(b).not(a).get()).length != 0)
						d3.selectAll(".siteInstanceView").remove();
				}
				
			  	// save this data in the object and render the svg region for all individual site instances
			  	var svg = d3.select("#siteInstancesTarget").selectAll("svg")
				    .data(initData)
				    .enter()
			    	.append("svg")
						.attr("id", function(d) {return "_" + d.instance_id + '_' + d.advisory_number;} )
						.attr("class", "siteInstanceView")
						.attr("width", siteInstance.width() + 30)
						.attr("height", function(d) { // if this is an exited run collapse it by default
							if(d.instance_status == _CONST_INSTANCE_EXIT_MSG_TYPE) 
								return '21'; 
							else 
								return '75';
							} )
						.append("g")
							.attr("transform", "translate(" + siteInstance.margin().left + "," + siteInstance.margin().top + ")")
							.call(siteInstance);				  		
				
				// create a region for the textual information
			  	var title = svg.append("g")
			      	.attr("transform", "translate(0, -5)");
			
				// handle the expand/collapse image area that controls each view instance
				title.append("image")
				    .attr("xlink:href", "/static/ASGS_Mon/images/down2.gif")
				    .attr("width", 13)
				    .attr("height", 13)
					.attr("x", -14)
					.attr("y", -11)
					.on("click", function(d) 
					{
						// get a ref to the site instance rect (main rect for each instance)
						si = d3.select("#_" + d.instance_id + '_' + d.advisory_number);
						
						// get the size of the event message summary rect
						msgRect = d3.select("#_" + d.instance_id + '_' + d.advisory_number + "_rect");
						
						// reset the event message area
						msgRect.transition()
							.duration(300)
								.attr("height", "15")

						// if the entire control is large
						if(parseInt(si.style('height')) >= 75)
						{
							// make it small, showing only the header
							si.transition()
								.duration(300)
									.attr("height", "21");
							
							// adjust the direction image
							d3.select(this).attr({"xlink:href": "/static/ASGS_Mon/images/up2.gif"});
						}
						// shrink the entire control
						else
						{
							// make it full size
							si.transition()
								.duration(300)
								.attr("height", "75");
															
							// adjust the direction image
							d3.select(this).attr({"xlink:href": "/static/ASGS_Mon/images/down2.gif"});
						}
					})

				// append the site name
				title.append("text")
				    .text(function(d) { return d.title + " - " + d.instance_name; })
				    .attr("class", "title");
			  	  
				// append the process run state. colored RGB later
				title.append("text")
					.text("Loading...")
					.attr("id", function(d) { return "_" + d.instance_id + '_' + d.advisory_number + "_state"; })
					.attr("class", "stateSm")
		      		.attr("fill", "gray")
					.attr("x", siteInstance.width()/2 - 90);

				// append the event operation message text that goes inside the bar graph
				svg.append("g")
					.attr("transform", "translate(6," + siteInstance.height() / 2 + ")")
					.append("text")
						.text("Loading...")
						.attr("id", function(d) { return "_" + d.instance_id + '_' + d.advisory_number + "_operation"; })
			      		.attr("fill", "gray")
						.attr("class", "state")
						.attr("dy", ".35em");

				// append the run parameters text
				svg.append("g")
			      	.style("text-anchor", "end")
					.attr("transform", "translate(" + siteInstance.width() + ", -5)")
					.append("text")
						.attr("id", function(d) { return "_" + d.instance_id + '_' + d.advisory_number + "_params"; })
						.attr("class", "params")
						.text(function(d) { return "Params: " + d.run_params; });					 	 		

				// create a rect for the event summary text
				var lastEventBox = svg.append("g")
		      		.attr("transform", "translate(-9, 36)");
				
				// load the event messages rectangle
				lastEventBox.append("rect")
					.attr("id", function(d) { return "_" + d.instance_id + '_' + d.advisory_number + "_rect"; })
					.attr("class", "eventBox")
					.attr("height", 15)
					.attr("width", 0)
					.on("click", function(d) 
					{
						// get a ref to the rectangle the event msg is in
						msgRect = d3.select("#_" + d.instance_id + '_' + d.advisory_number + "_rect");

						// get a ref to the site instance
						si = d3.select("#_" + d.instance_id + '_' + d.advisory_number);
														
				    	// get a reference to the event text area
				    	var textarea = d3.select("#_" + d.instance_id + '_' + d.advisory_number + "_eventSummary");
					  
				    	// remove all instances of the current text messages
				    	textarea.selectAll("text").remove();

				    	var eventMsgs = null;
				    	
				    	// spin through the instances to find the one we are handling here
				    	latestData.forEach(function(info)
				    	{
				    		if(info.instance_id == d.instance_id && info.advisory_number == d.advisory_number)
				    		{
						    	// get the event messages
				    			eventMsgs = info.event_raw_msgs; //d.event_raw_msgs;
				    		}
				    	});				    	

						// if it is large, make it small
						if(parseInt(msgRect.node().getBoundingClientRect().height) >= 75)
						{
							// make the entire control small size
							si.transition()
								.duration(100)
								.attr("height", "75")

							// make the event message area small
							msgRect.transition()
								.duration(100)
								.attr("height", "15")		
																			
							// insert the event area message text
				    		textarea
						    	.append("text")
								.attr("class", "eventSummary")
							    .text(function(d) 
							    	{
							    		var ellipsis = '';
							    		
							    		if(eventMsgs[0].event_summary.length > 130)
							    			ellipsis = '...';

							    		return eventMsgs[0].event_summary.substring(0, 130) + ellipsis; 
							    	})
								;
						}
						// if the message area is small, make it large
						else
						{
							// make the entire control full size
							si.transition()
								.duration(300)
								.attr("height", "135")											

							// make the message area large, showing all messages
							msgRect.transition()
								.duration(300)
								.attr("height", "75")						
									
					    	// loop through the messages and display them
						    eventMsgs.forEach(function(info, i)
						    	{
						    		// output the text
						    		textarea
								    	.append("text")
								    	.attr("class", "eventSummary")
								    	.attr("transform", "translate(0, " + (i * 10) + ")")
									    .text(function(d) 
									    	{
									    		var ellipsis = '';
									    		
									    		if(info.event_summary.length > 130)
									    			ellipsis = '...';

									    		return info.event_summary.substring(0, 130) + ellipsis; 
									    	})
								    	;
						    	});
						}
					})							
					.transition()
						.duration(1000)
						.attr("width", 595);

				// output a place holder for the eventual event summary text
	      		lastEventBox.append("g")				
		      		.attr("transform", "translate(3, 11)")
					.attr("id", function(d) { return "_" + d.instance_id + '_' + d.advisory_number + "_eventSummary"; });
			});
			
			// load the shells for all the site instance events
			d3.json("dataReq/?type=event" + "&viewActiveFlag=" + viewActiveFlag + "&viewInactiveFlag=" + viewInactiveFlag + "&sinceDate=" + sinceDate, function(error, eventData)
			{				
				// erase all the site instances on error
				if (error || eventData.length == 0) 
				{
					d3.selectAll(".siteInstanceView").remove();
					return;
				}
				
	 	 		// get a reference to the visualization component
	 			var svg = d3.select("#siteInstancesTarget").selectAll("svg");
	 			
	 	 		// reload the visualization with the new data
	 			svg.data(eventData).call(siteInstance.duration(1500));
			});
 		}
 	}
}
