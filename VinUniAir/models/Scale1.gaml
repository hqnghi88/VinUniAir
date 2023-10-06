/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main

import "main2.gaml"

global {
	float step <- 10 #s;
	shape_file roads_shape_file <- shape_file("../includes/bigger_map/hanoi_roads.shp");
	//	shape_file dummy_roads_shape_file <- shape_file(resources_dir + "vinuniroad.shp");
	shape_file buildings_shape_file <- shape_file("../includes/bigger_map/hanoi2.shp");
	//	shape_file road_cells_shape_file <- shape_file(resources_dir + "road_cells.shp");
	//	shape_file naturals_shape_file <- shape_file(resources_dir + "naturals.shp");
	//	shape_file buildings_admin_shape_file <- shape_file(resources_dir + "buildings_admin.shp");
	geometry shape <- envelope(buildings_shape_file);
	float WW <- world.shape.width / 1184.1165564209223;
	float HH <- world.shape.height / 929.0766558628529;

	init {
		sizeCoeff <- 100;
		create progress_bar with: [x::WW * 1300, y::20 * HH, width::250 * WW, height::20 * HH, max_val::500, title::"Cars", left_label::"0", right_label::"Max", scale::HH];
		create progress_bar with: [x::WW * 1300, y::100 * HH, width::250 * WW, height::20 * HH, max_val::500, title::"Motorbikes", left_label::"0", right_label::"Max", scale::HH];
		create progress_bar with: [x::WW * 1300, y::180 * HH, width::500 * WW, height::20 * HH, max_val::1000, title::"Green Taxi", left_label::"0", right_label::"Max", scale::HH];
		//		create param_indicator with: [x::1300, y::850, size::22, name::"Road scenario", value::"No blocked roads", with_RT::true];
		//		create param_indicator with: [x::1300, y::1050, size::22, name::"Display mode", value::"Traffic"];

		//		create background with: [x::2450, y::1000, width::1250, height::1500, alpha::0.6];
		//		create line_graph with: [x::2500, y::1400, width::1200, height::1000, label::"Hourly AQI"];
		create line_graph_aqi with: [x::WW * 1300, y::250 * HH, width::500 * WW, height::200 * HH, label::"Hourly AQI", thick::50];
		//		create indicator_health_concern_level with: [x::2800, y::2803, width::800, height::200];
		create param_indicator with: [x::WW * 1300, y::460 * HH, size::30, name:: "Time", value:: "00:00:00", with_box::true, width::500 * WW, height::20 * HH];
	}

	//	reflex produce_pollutant {
	//		ask road { 
	//			speed_coeff <- rnd(12);
	//		}
	//
	//	}

}

experiment exp1 {
	parameter "Number of cars" var: n_cars <- 0 min: 0 max: 500;
	parameter "Number of motorbikes" var: n_motorbikes <- 0 min: 0 max: 500;
	parameter "Number of greentaxi" var: n_taxi <- 0 min: 0 max: 1000;
	output synchronized: true {
		display main type: opengl background: #black axes: false {
		//			camera 'default' location: {581.6792, 1227.6974, 388.9891} target: {568.1048, 450.0203, 0.0};
			image ("../includes/bigger_map/hanoi.png") position: {0, 0, -0.001};

			//			graphics toto {
			//				draw static_map_request;
			//			}
			//			species vehicle;
			species road position: {1300 * WW, 550 * HH, 0} size: {0.5, 0.5} {
				draw shape color: #darkgray;
			}

			species taxi_random position: {1300 * WW, 550 * HH, 0} size: {0.5, 0.5} {
				point pos <- compute_position();
				draw circle(50) at: pos rotate: heading depth: 1 * sizeCoeff;
			}
			//			species natural;
			species road position: {0, 0, 0.001};
			species building aspect: border refresh: false position: {0, 0, 0.001};
			species car_random aspect: base;
			species motorbike_random aspect: base;
			species taxi_random position: {0, 0, 0.002} {
			//				draw circle(10);
				point pos <- compute_position();
				draw circle(10) at: pos rotate: heading depth: 1 * sizeCoeff;
			}
			//	species background;
			species progress_bar;
			species param_indicator;
			//		species line_graph;
			species line_graph_aqi position: {0, 0, -0.001};
			species indicator_health_concern_level;
			//			grid pollutant_grid elevation:pollution<0?0.0:pollution/10 transparency: 0.5 triangulation:true position:{0,0,-0.0001} ;
			//			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: palette([#white, #white, #orange, #orange, #red, #red, #red]) smooth: 2 position: {0, 0, -0.00001};
			//			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: scale([#white::0, #yellow::1, #orange::2, #red::6]) smooth: 1 position: {0, 0, -0.001};
			mesh instant_heatmap scale: 1 above: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1 position: {0, 0, 0.001};
		}

	}

}