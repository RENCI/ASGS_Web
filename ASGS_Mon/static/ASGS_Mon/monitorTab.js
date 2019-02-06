/*****
 * Renders all site/instance elements
 * 
 * @returns nothing. It renders the tab contents or it doesn't.
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
			var viewAllActiveFlag = $('#viewAllActive').is(":checked");
			
			// get the value of the view all since filter
			var viewAllSinceFlag = $('#viewAllActive').is(":checked");
			
			// get the since date
			var sinceDate = ($('#sinceDate').val() == '') ? '1/1/2010' : $('#sinceDate').val();
			
			// get the value of the view exited filter
			var viewExitedFlag = $('#viewExited').is(":checked");
	
			// get the value of the view stalled filter
			var viewStalledFlag = $('#viewStalled').is(":checked");
			
			// set the exited run type id
			var _CONST_EXIT_MSG_TYPE = 9;

			// create/init the shells for all the site instances
			d3.json("dataReq/?type=init" + "&viewAllSinceFlag=" + viewAllActiveFlag + "&viewStalledFlag=" + viewStalledFlag + "&sinceDate=" + sinceDate, function(error, initData)
			{				
				// erase all the site instances on error
				if (error || initData.length == 0 || initData == 'None') 
				{
					d3.selectAll(".siteInstanceView").remove();
					
					//d3.select("#siteInstancesTarget").style('color', 'red').text('There is nothing to see here with your filter selections.');
				
					return;
				}
					
				// get the current rendered items
				var curRendered = d3.selectAll(".siteInstanceView").selectAll("svg");

				// do we have a valid site instance defined
				if(Array.isArray(curRendered))
				{
					// loop through the rendered site instances and remove ones with no incoming data 
					for(i=0; i<curRendered.length; i++)
					{
						// reset the found flag
						bfound = false;
						
						// for each id in the incoming data
						for(j=0; j<initData.length; j++)
						{
							// was it previously rendered
							if(curRendered[i].parentNode.id == "_" + initData[j].instance_id)
							{
								// set the flag
								bfound = true;
								
								// no need to continue
								break;
							}
						}
						
						// if data for this rendered item is not found remove it
						if(!bfound)
							curRendered[i].parentNode.remove();
					}
				}
				
			  	// save this data in the object and render the svg region for all individual site instances
			  	var svg = d3.select("#siteInstancesTarget").selectAll("svg")
				    .data(initData)
				    .enter()
			    	.append("svg")
						.attr("id", function(d) {return "_" + d.instance_id;} )
						.attr("class", "siteInstanceView")
						.attr("width", siteInstance.width() + 30)
						.attr("height", function(d) { // if this is an exited run collapse it by default
							if(d.instance_status == _CONST_EXIT_MSG_TYPE) 
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
						si = d3.select("#_" + d.instance_id);
						
						// get the size of the event message summary rect
						msgRect = d3.select("#_" + d.instance_id + "_rect");
						
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
					.attr("id", function(d) { return "_" + d.instance_id + "_state"; })
					.attr("class", "stateSm")
		      		.attr("fill", "gray")
					.attr("x", siteInstance.width()/2 - 90);

				// append the event operation message text that goes inside the bar graph
				svg.append("g")
					.attr("transform", "translate(6," + siteInstance.height() / 2 + ")")
					.append("text")
						.text("Loading...")
						.attr("id", function(d) { return "_" + d.instance_id + "_operation"; })
			      		.attr("fill", "gray")
						.attr("class", "state")
						.attr("dy", ".35em");

				// append the run parameters text
				svg.append("g")
			      	.style("text-anchor", "end")
					.attr("transform", "translate(" + siteInstance.width() + ", -5)")
					.append("text")
						.attr("id", function(d) { return "_" + d.instance_id + "_params"; })
						.attr("class", "params")
						.text(function(d) { return "Params: " + d.run_params; });					 	 		

				// create a rect for the event summary text
				var lastEventBox = svg.append("g")
		      		.attr("transform", "translate(-9, 36)");
				
				// load the event messages rectangle
				lastEventBox.append("rect")
					.attr("id", function(d) { return "_" + d.instance_id + "_rect"; })
					.attr("class", "eventBox")
					.attr("height", 15)
					.attr("width", 0)
					.on("click", function(d) 
					{
						// get a ref to the rectangle the event msg is in
						msgRect = d3.select("#_" + d.instance_id + "_rect");

						// get a ref to the site instance
						si = d3.select("#_" + d.instance_id);
														
				    	// get a reference to the event text area
				    	var textarea = d3.select("#_" + d.instance_id + "_eventSummary");
					  
				    	// remove all instances of the current text messages
				    	textarea.selectAll("text").remove();

				    	// get the event messages from the site instance. this is the latest.
					    var eventMsgs = si[0][0].__data__.event_raw_msgs; //d.event_raw_msgs;

						// if it is large, make it small
						if(parseInt(msgRect.node().getBoundingClientRect().height) >= 75)
						{
							// make the entire control small size
							si.transition()
								.duration(300)
								.attr("height", "75")

							// make the event message area small
							msgRect.transition()
								.duration(300)
								.attr("height", "15")		
																			
							// insert the event area message text
				    		textarea
						    	.append("text")
								.attr("class", "eventSummary")
							    .text(function(d) 
							    	{
							    		var ellipsis = '';
							    		
							    		if(eventMsgs[0].event_summary.length > 120)
							    			ellipsis = '...';

							    		return eventMsgs[0].event_summary.substring(0, 120) + ellipsis; 
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
									    		
									    		if(info.event_summary.length > 120)
									    			ellipsis = '...';

									    		return info.event_summary.substring(0, 120) + ellipsis; 
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
					.attr("id", function(d) { return "_" + d.instance_id + "_eventSummary"; });
			});
			
			// create/init the shells for all the site instances
			d3.json("dataReq/?type=event" + "&viewAllSinceFlag=" + viewAllActiveFlag + "&viewStalledFlag=" + viewStalledFlag + "&sinceDate=" + sinceDate, function(error, eventData)
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
