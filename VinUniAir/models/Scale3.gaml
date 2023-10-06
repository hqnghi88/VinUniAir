/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main

import "main.gaml"

global {

// Benchmark execution time 
	float step <- 1 #s;
	// Load shapefiles  
	shape_file roads_shape_file <- shape_file("../includes/bigger_map/roads.shp");
	shape_file buildings_shape_file <- shape_file("../includes/bigger_map/buildings.shp");
	shape_file intersect0_shape_file <- shape_file("../includes/bigger_map/inter.shp");
	geometry shape <- envelope(roads_shape_file);
	//	list<road> open_roads;
	float traffic_light_interval <- 180 #s; //parameter: 'Traffic light interval' init: 60 #s;

	//	list<pollutant_grid> active_cells;
	init {
		sizeCoeff <- 1;
		write shape.width;
		write shape.height;
		create progress_bar with: [x::1300, y::20, width::250, height::20, max_val::500, title::"Cars", left_label::"0", right_label::"Max"];
		create progress_bar with: [x::1300, y::100, width::250, height::20, max_val::500, title::"Motorbikes", left_label::"0", right_label::"Max"];
		create progress_bar with: [x::1300, y::180, width::500, height::20, max_val::1000, title::"Green Taxi", left_label::"0", right_label::"Max"];
		//		create param_indicator with: [x::1300, y::850, size::22, name::"Road scenario", value::"No blocked roads", with_RT::true];
		//		create param_indicator with: [x::1300, y::1050, size::22, name::"Display mode", value::"Traffic"];

		//		create background with: [x::2450, y::1000, width::1250, height::1500, alpha::0.6];
		//		create line_graph with: [x::2500, y::1400, width::1200, height::1000, label::"Hourly AQI"];
		create line_graph_aqi with: [x::1300, y::250, width::500, height::200, label::"Hourly AQI"];
		//		create indicator_health_concern_level with: [x::2800, y::2803, width::800, height::200];
		create param_indicator with: [x::1300, y::460, size::30, name:: "Time", value:: "00:00:00", with_box::true, width::500, height::20];
	}

}

experiment exp3 parent: exp {
	output synchronized: true {
		display main type: opengl background: #black axes: false {
			camera 'default' location: {927.7065, 536.4046, 1799.9519} target: {927.7065, 536.3731, 0.0};
			image ("../includes/bigger_map/vin.png");

			//			graphics toto {
			//				draw static_map_request;
			//			}
			//			species vehicle;
			species road position: {1300, 550, 0} size: {0.5, 0.5} {
				draw shape color: #darkgray;
			}

			species taxi_random position: {1300, 550, 0} size: {0.5, 0.5} {
				if (current_road != nil) {
					point pos <- compute_position();
					draw circle(4) at: pos color: color;
				}

			}

			species intersection aspect: base position: {1300, 550, 0} size: {0.5, 0.5};
			//			species natural;
			species road;
			species building;
			species car_random aspect: base;
			species motorbike_random aspect: base;
			species taxi_random aspect: base;
			//	species background;
			species progress_bar;
			species param_indicator;
			//		species line_graph;
			species line_graph_aqi position: {0, 0, -0.001};
			species indicator_health_concern_level;
			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1 position: {0, 0, -0.001};
		}

	}

}