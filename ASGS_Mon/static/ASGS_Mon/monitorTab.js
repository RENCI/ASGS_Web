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

// global for the storage of the last set of event messages
var latestData;

// the last time messages were acquired
var chatMsgsSince = '';

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
			// get the current date
			d = new Date();

			// update the current NCEP cycle number
			$("#NCEP_cycle").text(formatNCEPTime(d));
			$("#local_Time").text(formatLocalAMPM(d));

			// get the value of the view all since filter
			var viewActiveFlag = $('#viewActive').is(":checked");
			
			// get the since date
			var sinceDate = $('#sinceDate').val();
			
			// array for the selected inactives 
	        var inactives = [];
	        
			// get all the selected values into an array
	        $.each($("#inactiveFilter option:selected"), function(){            
	        	inactives.push($(this).val());
	        });	
			
			// array for the selected sites
	        var sites = [];
	        
	        // get all the selected values into an array
	        $.each($("#siteFilter option:selected"), function(){            
	        	sites.push($(this).val());
	        });	        

	        // load up the filter selections
	        var viewFilterTitle = [];
	        	        
	        // view active?
	        if(viewActiveFlag == false)
	        	viewFilterTitle.push(" Active disabled");
	        
	        // view inactives?
	        if(inactives.length > 0)
	        	viewFilterTitle.push(" Inactive enabled");
	        
	        // view specific sites?
	        if(sites.length > 0)
	        	viewFilterTitle.push(" Site selection enabled");

	        // view since?
	        if(sinceDate.length > 0)
	        	viewFilterTitle.push(" Since " + sinceDate + " enabled");       	
	        
   			// update the view filter selection if needed
	        if(viewFilterTitle.length > 0)
	        	$("#viewFilterArea").text("(Filters: " + viewFilterTitle.toString() + ")");
	        else if ($("#viewFilterArea").text().length > 0)
	        	$("#viewFilterArea").text("");
	        	        	
	        // get the chat messages
	        d3.json("dataReq?type=chatmsgs&sinceDate=" + chatMsgsSince, function(error, chatMsgData)
			{		
				// if we got good data put it away
				if (error == null && chatMsgData.length != 0 && chatMsgData != 'None') 
				{ 
					// put away the chat messages
					chatMsgData.forEach(function(info, i) { addChatMessage(info.msg_ts + ' - ' + info.username + ' says:<br>' + info.message); }); 
					
					scrollToBottom();
					
		        	// save the timeestamp for filtering messages created after this load.
					chatMsgsSince = formatDateTime(d);
					
					// if the chat box is already open do not set the glyph
					if($("#chatMsgArea")[0].clientHeight <= 0)
						$("#chatBtnI").addClass("fa fa-eye");
				}				
			});
	        
			// create/init the shells for all the site instances
			d3.json("dataReq?type=init" + "&viewActiveFlag=" + viewActiveFlag + "&inactives=" + inactives.toString() + "&sinceDate=" + sinceDate + "&sites=" + sites.toString(), function(error, initData)
			{				
				// erase all the site instances on error or no data
				if (error || initData.length == 0 || initData == 'None') 
				{
					// remove the site/advisory instances
					d3.selectAll(".siteInstanceView").remove();
					
					// show the no data message
					$("#filterMsg").show(1000);
					
		        	$("#siteCount").text("");

		        	return;
				}
				else
				{
					$("#filterMsg").hide(0);
					
		   			// update the instances in view count
		        	$("#siteCount").text("(Currently displaying " + initData.length + " site instance(s).)");		        			        	
				}
				
				// save this data for the event message rendering later
				latestData = initData;
				theGridData[0] = initData;
				
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
						a.push("_" + initData[i].instance_id + '_' + initData[i].eg_id);
					
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
						.attr("id", function(d) {return "_" + d.instance_id + '_' + d.eg_id;} )
						.attr("class", "siteInstanceView")
						.attr("width", siteInstance.width() + 30)
						.attr("height", function(d) { // if this is an exited or erred run collapse it by default
							if(d.instance_status == _CONST_INSTANCE_EXIT_MSG_TYPE || d.instance_status == _CONST_INSTANCE_FAIL_MSG_TYPE) 
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
				    .attr("xlink:href", function(d) 
				    		{ 
				    			// if this is an exited or erred run collapse it by default
								if(d.instance_status == _CONST_INSTANCE_EXIT_MSG_TYPE || d.instance_status == _CONST_INSTANCE_FAIL_MSG_TYPE) 
									return staticDir + 'ASGS_Mon/images/up2.gif'; 
								else 
									return staticDir + 'ASGS_Mon/images/down2.gif';
				    		})
				    .attr("width", 13)
				    .attr("height", 13)
					.attr("x", -14)
					.attr("y", -11)
					.on("click", function(d) 
					{
						// get a ref to the site instance rect (main rect for each instance)
						si = d3.select("#_" + d.instance_id + '_' + d.eg_id);
						
						// get the size of the event message summary rect
						msgRect = d3.select("#_" + d.instance_id + '_' + d.eg_id + "_rect");
						
						// reset the event message area
						msgRect.transition()
							.duration(300)
								.attr("height", "15")

						// if the entire control is large
						if(parseInt(si.style('height')) >= 70)
						{
							// make it small, showing only the header
							si.transition()
								.duration(300)
									.attr("height", "21");
							
							// adjust the direction image
							d3.select(this).attr({"xlink:href": staticDir + 'ASGS_Mon/images/up2.gif'});
						}
						// shrink the entire control
						else
						{
							// make it full size
							si.transition()
								.duration(300)
								.attr("height", "75");
															
							// adjust the direction image
							d3.select(this).attr({"xlink:href": staticDir + 'ASGS_Mon/images/down2.gif'});
						}
					})

				// append the site name
				title.append("text")
				    .text(function(d) { return d.title + " - " + d.instance_name; })
				    .attr("class", "title");
			  	  
				// append the process run state. colored RGB later
				title.append("text")
					.text("Loading...")
					.attr("id", function(d) { return "_" + d.instance_id + '_' + d.eg_id + "_state"; })
					.attr("class", "stateSm")
		      		.attr("fill", "gray")
					.attr("x", siteInstance.width()/2 - 45);

				// append the event operation message text that goes inside the bar graph
				svg.append("g")
					.attr("transform", "translate(6," + siteInstance.height() / 2 + ")")
					.append("text")
						.text("Loading...")
						.attr("id", function(d) { return "_" + d.instance_id + '_' + d.eg_id + "_operation"; })
			      		.attr("fill", "gray")
						.attr("class", "state")
						.attr("dy", ".35em");

				// append the run parameters text
				svg.append("g")
			      	.style("text-anchor", "end")
					.attr("transform", "translate(" + (siteInstance.width()+10) + ", -5)")
					.append("text")
						.attr("id", function(d) { return "_" + d.instance_id + '_' + d.eg_id + "_params"; })
						.attr("class", "params")
						.text(function(d) { return "Params: " + d.run_params; });					 	 		

				// create a rect for the event summary text
				var lastEventBox = svg.append("g")
		      		.attr("transform", "translate(-9, 36)");
				
				// load the event messages rectangle
				lastEventBox.append("rect")
					.attr("id", function(d) { return "_" + d.instance_id + '_' + d.eg_id + "_rect"; })
					.attr("class", "eventBox")
					.attr("height", 15)
					.attr("width", 3)						
					.transition()
						.duration(1000)
						.attr("width", 595);

				// output a place holder for the eventual event summary text
	      		lastEventBox.append("g")				
		      		.attr("transform", "translate(3, 11)")
					.attr("id", function(d) { return "_" + d.instance_id + '_' + d.eg_id + "_eventSummary"; })
					.on("click", function(d) 
					{
						// get a ref to the rectangle the event msg is in
						msgRect = d3.select("#_" + d.instance_id + '_' + d.eg_id + "_rect");

						// get a ref to the site instance
						si = d3.select("#_" + d.instance_id + '_' + d.eg_id);
														
				    	// get a reference to the event text area
				    	var textarea = d3.select("#_" + d.instance_id + '_' + d.eg_id + "_eventSummary");
					  
				    	// remove all instances of the current text messages
				    	textarea.selectAll("foreignObject").remove();

				    	// storage for the event msgs for this instance
				    	var eventMsgs = null;
				    	
				    	// spin through the instances to find the one we are handling here
				    	latestData.forEach(function(info)
				    	{
				    		// is this the event msg we are looking for
				    		if(info.instance_id == d.instance_id && info.eg_id == d.eg_id)
				    		{
						    	// save the event messages
				    			eventMsgs = info.event_raw_msgs; //d.event_raw_msgs;
				    		}
				    	});				    	

					    // if the event message text area is expanded output all the latest messages 
					    // note: i am keying off the size of the message area to make this determination.
					    // apparently this can be +/- a pixel depending on the browser scaling.
					    // so although the rect area is set to 75 sometimes it is 74.
						if(parseInt(msgRect.node().getBoundingClientRect().height) >= 70)
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
								.append("foreignObject")
								.attr("width", msgRect.node().getBoundingClientRect().width-3)
								.attr("height", 11)
								.attr("x", 0)
								.attr("y", -9)
								.append("xhtml:div")
									.attr("class", "eventSummary")
									.html(eventMsgs[0].event_summary);
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
								// output the event message text
								textarea
									.append("foreignObject")
									.attr("transform", "translate(0, " + (i * 10) + ")")
									.attr("width", msgRect.node().getBoundingClientRect().width-3)
									.attr("height", 11)
									.attr("x", 0)
									.attr("y", -9)
									.append("xhtml:div")
										.attr("class", "eventSummary")
										.html(info.event_summary);
					    	});
						}
					}
				)
				
				// load the shells for all the site instance events
				d3.json("dataReq?type=event" + "&viewActiveFlag=" + viewActiveFlag + "&inactives=" + inactives.toString() + "&sinceDate=" + sinceDate + "&sites=" + sites.toString(), function(error, eventData)
				{				
					// erase all the site instances on error
					if (error || eventData == "None" || eventData.length == 0) 
					{
						d3.selectAll(".siteInstanceView").remove();
						return;
					}
					
		 	 		// get a reference to the visualization component
		 			var svg = d3.select("#siteInstancesTarget").selectAll("svg");
		 			
		 	 		// reload the visualization with the new data
		 			svg.data(eventData).call(siteInstance.duration(1500));
		 			
		 			theGridData[1] = eventData;
		 			
		 			renderGridView(globalSortOn);
				});
			});			
 		}
 	}
}

var globalSortOn = null;
var previousSort = null;
var format = d3.time.format("%a %b %d %Y");
var theGridData = [null, null];

renderGridView(null);

/**
 * Renders the grid view with data from the database
 * 
 * @param enventData - the data from the database
 * 
 */
function renderGridView(sortOn)
{	
	// set the margins of the grid in the tab
	var 
		margin = {top: 20, right: 10, bottom: 5, left: 10},
		width = 1500 - margin.left - margin.right,
		height = 800 - margin.top - margin.bottom;
	
	// clear out what is in the grid
	d3.select("#gridDataView").html('');
	
	// get a handle to the grid view area and set the dimensions
	var gridDataArea = d3.select("#gridDataView")
		.attr("width", "100%")
		.attr("height", height + margin.top + margin.bottom)
		.append("g")
			.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
	
	// create the header and body of the grid table
	var headerGrp = gridDataArea.append("g").attr("class", "headerGrp");
	var rowsGrp = gridDataArea.append("g").attr("class","rowsGrp");
	
	// set the row height and cell width
	var fieldHeight = 25;
	var fieldWidth = 120;
		
	// save desired data
	var newGridData = [];
	
	// do we have all the data
	if(theGridData[1] != null)
	{
		// for each data row (site instance)
		for(var i=0; i<theGridData[1].length; i++)
		{			
			// save the instance id
			var instance_id = theGridData[1][i]['instance_id'];
			
			// reset the name for this pass
			var instance_name = '';
			
			// search for the instance we are look at
			for(j=0; j<theGridData[0].length; j++)
			{
				// did we get a match
				if(theGridData[0][j].instance_id == instance_id)
				{
					// save the instance name
					instance_name = theGridData[0][j].instance_name.substr(0, 20);
					
					// no need to continue
					break;
				}
			}
				
			if(instance_name != '')
			{
				// save the elements in a new format so the column name appear correctly
				elements = 
				{
					'Instance ID': theGridData[1][i]['instance_id'],
					'Instance': instance_name,
					'Advisory #': theGridData[1][i]['advisory_number'],
					'Cluster': theGridData[1][i]['cluster_name'],
					'State': theGridData[1][i]['cluster_state'],
					'Step': theGridData[1][i]['type'],
					'% complete': theGridData[1][i]['pct_complete'] + "% / " + theGridData[1][i]['markers'] + "%",
					'Last event': theGridData[1][i]['datetime']
				};
				
				// and save the new instance data to render
				newGridData.push(elements);
			}
		}
	}
	
	// create and fill in the table column header	
	var header = headerGrp.selectAll("g")
		.data(d3.keys(newGridData[0]))
		.enter().append("g")
		.attr("class", "header")
		.attr("transform", function (d, i){
			return "translate(" + i * fieldWidth + ",0)";
		});
		//.on("click", function(d){ return renderGridView(d);});
	
	// 
	header.append("rect")
		.attr("width", fieldWidth-1)
		.attr("height", fieldHeight);
		
	// 
	header.append("text")
		.attr("x", fieldWidth / 2)
		.attr("y", fieldHeight / 2)
		.attr("dy", ".35em")
		.text(String);
	
	// get the table data
	var rows = rowsGrp.selectAll("g.row").data(newGridData, function(d){ return d["Instance ID"] + d["Advisory #"]; });
	
	if(globalSortOn !== null)
		rows.sort(function(a,b){return sort(a[globalSortOn], b[globalSortOn]);});			
	
	// render the rows
	var rowsEnter = rows.enter().append("svg:g")
		.attr("class","row")
		.attr("transform", function (d, i){
			return "translate(0," + (i+1) * (fieldHeight+1) + ")";
		});
	
	// get the cell data
	var cells = rows.selectAll("g.cell").data(function(d){return d3.values(d);});
	
	// render the cells
	var cellsEnter = cells.enter().append("svg:g")
		.attr("class", "cell")
		.attr("transform", function (d, i){
			return "translate(" + i * fieldWidth + ",0)";
		});
		
	// 
	cellsEnter.append("rect")
		.attr("width", fieldWidth-1)
		.attr("height", fieldHeight);	
		
	// 
	cellsEnter.append("text")
		.attr("x", fieldWidth / 2)
		.attr("y", fieldHeight / 2)
		.attr("dy", ".35em")
		.text(String);
	
	// update if not in initialization
	if(sortOn !== null) 
	{
		globalSortOn = sortOn;
		
		// update rows
		if(sortOn != previousSort)
		{
			rows.sort(function(a,b){return sort(a[sortOn], b[sortOn]);});			
			previousSort = sortOn;
		}
		else
		{
			rows.sort(function(a,b){return sort(b[sortOn], a[sortOn]);});
			previousSort = null;
		}
		
		rows.transition()
			.duration(500)
			.attr("transform", function (d, i)
			{
				return "translate(0," + (i+1) * (fieldHeight+1) + ")";
			});
	}
}
	
// simple sorting
function sort(a, b)
{
	if(typeof a == "string")
	{
		var parseA = format.parse(a);
		
		if(parseA)
		{
			var timeA = parseA.getTime();
			var timeB = format.parse(b).getTime();
			return timeA > timeB ? 1 : timeA == timeB ? 0 : -1;
		}
		else 
			return a.localeCompare(b);
	}
	else if(typeof a == "number")
	{
		return a > b ? 1 : a == b ? 0 : -1;
	}
	else if(typeof a == "boolean")
	{
		return b ? 1 : a ? -1 : 0;
	}
}