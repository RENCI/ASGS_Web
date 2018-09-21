/*****
 * Renders all site/instance elements
 * 
 * @returns nothing. It renders the data or it doesnt.
 */
(function() 
{
	// definition of the site instance view
	d3.siteInstanceView = function() 
	{
		// init default view params
		var orient = "left";
	    var reverse = false;
	    var duration = 0;
	    var ranges = viewRanges;
	    var markers = viewMarkers;
	    var measures = viewMeasures;
	    var width = 380;
	    var height = 30;
	    var tickFormat = null;

		// render a site instance
		function siteInstanceView(g) 
		{
			// for each site/instance in the view
			g.each(function(d, i) 
			{
				// get the color of the state indicator for the cluster text
				if(d.cluster_state_id == "6" || d.cluster_state_id == "3")
					stateTextColor = "red"
			    else if(d.cluster_state_id == "2" || d.cluster_state_id == "4")
			    	stateTextColor = "goldenrod";
			    else
			    	stateTextColor = "green";

				// update the operation message text
				d3.select("#_" + d.instance_id + "_operation")
					.text(d.event_message)
		      		.attr("fill", "black");
							      
			    // update the site state indicator text
			    d3.select("#_" + d.instance_id + "_state")
			    	.text("Process " + d.cluster_state)
			    		.transition().duration(0)
			      		.attr("fill", "green")
			    	.transition().delay(0).duration(duration)
			      		.attr("fill", stateTextColor);		    			    
			    
			    // update the summary indicator
			    d3.select("#_" + d.instance_id + "_eventSummary")
			    	.text(d.datetime + " -  Advisory: " + d.advisory_number + ", Storm: " + d.storm + ", Message: " +  d.message)
		      		.attr("fill", "black")

			
				// get a reference to this element
				var g = d3.select(this);
			    
				// instance view is expanded flag 
				var isExpanded = true;
				
				// setup the bar graph details
				var rangez = ranges.call(this, d, i).slice().sort(d3.descending);
				var markerz = markers.call(this, d, i).slice().sort(d3.descending);
				var measurez = measures.call(this, d, i).slice().sort(d3.descending);
							
				// Compute the new x-scale.
				var x1 = d3.scale.linear()
					.domain([0, Math.max(rangez[0], markerz[0], measurez[0])])
						.range(reverse ? [width, 0] : [0, width]);
			
				// Retrieve the old x-scale, if this is an update.
				var x0 = this.__chart__ || d3.scale.linear()
					.domain([0, Infinity])
						.range(x1.range());
			
				// save the new scale.
				this.__chart__ = x1;
			
				// Derive width-scales from the x-scales.
				var w0 = viewWidth(x0);
				var w1 = viewWidth(x1);
												
				// Update the range rect
				var range = g.selectAll("rect.range").data(rangez);
	
				range.enter().append("rect")
					.attr("class", function(d, i) { return "range s" + i; })
					.attr("width", w0)
					.attr("height", height)
					.attr("x", reverse ? x0 : 0)
				.transition()
					.duration(duration)
						.attr("width", w1)
						.attr("x", reverse ? x1 : 0);
	
				range.transition()
					.duration(duration)
						.attr("x", reverse ? x1 : 0)
						.attr("width", w1)
						.attr("height", height);
	
				// get the color of the state indicator for the event group progress bar
				if(d.group_state_id == "6" || d.group_state_id == "3")
					measureColor = "#F08080"
				else if(d.group_state_id == "2" || d.group_state_id == "4")
					measureColor = "goldenrod";
				else
					measureColor = "darkseagreen";      
	
				// Update the measure rects
				var measure = g.selectAll("rect.measure").data(measurez);
	
				measure.enter().append("rect")
					.attr("class", "measure")
					.attr("width", w0)
					.attr("height", height / 1) 
					.attr("x", reverse ? x0 : 0)
					.attr("y", 0)
					.transition()
						.duration(duration)
							.attr("width", w1)
							.attr("x", reverse ? x1 : 0);
	
				measure.transition()
					.duration(duration)
						.attr("width", w1)
						.attr("height", height / 1)
						.attr("x", reverse ? x1 : 0)
						.attr("y", 0)
						.attr("fill", measureColor);
	
				// Update the marker lines.
				var marker = g.selectAll("line.marker").data(markerz);
	
				marker.enter().append("line")
					.attr("class", "marker")
					.attr("x1", x0)
					.attr("x2", x0)
					.attr("y1", height / 6)
					.attr("y2", height * 5 / 6)
					.transition()
						.duration(duration)
							.attr("x1", x1)
							.attr("x2", x1);
				
				marker.transition()
					.duration(duration)
						.attr("x1", x1)
						.attr("x2", x1)
						.attr("y1", height / 6)
						.attr("y2", height * 5 / 6);
	
				// Compute the tick format.
				var format = tickFormat || x1.tickFormat(8);
	
				// Update the tick groups.
				var tick = g.selectAll("g.tick")
					.data(x1.ticks(8), function(d) 
					{
						return this.textContent || format(d);
					});
	
				// Initialize the ticks with the old scale, x0.
				var tickEnter = tick.enter().append("g")
					.attr("class", "tick")
					.attr("transform", viewTranslate(x0))
						.style("opacity", 1e-6);
	
				tickEnter.append("line")
					.attr("y1", height)
					.attr("y2", height * 7 / 6);
	
				tickEnter.append("text")
					.attr("text-anchor", "middle")
					.attr("dy", "1em")
					.attr("y", height * 7 / 6)
						.text(format);
	
				// Transition the entering ticks to the new scale, x1.
				tickEnter.transition()
					.duration(duration)
						.attr("transform", viewTranslate(x1))
							.style("opacity", 1);
				
				// Transition the updating ticks to the new scale, x1.
				var tickUpdate = tick.transition()
					.duration(duration)
						.attr("transform", viewTranslate(x1))
							.style("opacity", 1);
				
				tickUpdate.select("line")
					.attr("y1", height)
					.attr("y2", height * 7 / 6);
				
				tickUpdate.select("text")
					.attr("y", height * 7 / 6);
				
				// Transition the exiting ticks to the new scale, x1.
				tick.exit()
					.transition()
						.duration(duration)
						.attr("transform", viewTranslate(x1))
							.style("opacity", 1e-6)
								.remove();	
			});
			
			d3.timer.flush();
		}
	
		// left, right, top, bottom
		siteInstanceView.orient = function(x) 
		{
			if (!arguments.length) 
				return orient;
			
			orient = x;
			reverse = orient == "right" || orient == "bottom";
			
			return siteInstanceView;
		};
	
		// ranges (bad, satisfactory, good)
		siteInstanceView.ranges = function(x) 
		{
			if (!arguments.length) return ranges;
				ranges = x;
			
			return siteInstanceView;
		};
		
		// markers (previous, goal)
		siteInstanceView.markers = function(x) 
		{
			if (!arguments.length) return markers;
				markers = x;
				
			return siteInstanceView;
		};
		
		// measures (actual, forecast)
		siteInstanceView.measures = function(x) 
		{
			if (!arguments.length) return measures;
				measures = x;
		
			return siteInstanceView;
		};
		
		siteInstanceView.width = function(x) 
		{
			if (!arguments.length) return width;
				width = x;
		
			return siteInstanceView;
		};
		
		siteInstanceView.height = function(x) 
		{
			if (!arguments.length) return height;
				height = x;
			
			return siteInstanceView;
		};
		
		siteInstanceView.tickFormat = function(x) 
		{
			if (!arguments.length) return tickFormat;
				tickFormat = x;
		
			return siteInstanceView;
		};
		
		siteInstanceView.duration = function(x) 
		{
			if (!arguments.length) return duration;
				duration = x;
				
			return siteInstanceView;
		};
	
		return siteInstanceView;
	};
	
	function viewRanges(d) 
	{
		return d.ranges;
	}
	
	function viewMarkers(d) 
	{
		return d.markers;
	}
	
	function viewMeasures(d) 
	{
		return d.measures;
	}
	
	function viewTranslate(x) 
	{
		return function(d) 
		{
			return "translate(" + x(d) + ", 0)";
		};
	}
	
	function viewWidth(x) 
	{
		var x0 = x(0);
	  
		return function(d) 
		{
			return Math.abs(x(d) - x0);
		};
	}
})();