/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main

import "main.gaml"

global {
	float step <- 10 #s;
	shape_file roads_shape_file <- shape_file("../includes/bigger_map/hanoi_roads.shp");
	//	shape_file dummy_roads_shape_file <- shape_file(resources_dir + "vinuniroad.shp");
	shape_file buildings_shape_file <- shape_file("../includes/bigger_map/hanoi2.shp");
	//	shape_file road_cells_shape_file <- shape_file(resources_dir + "road_cells.shp");
	//	shape_file naturals_shape_file <- shape_file(resources_dir + "naturals.shp");
	//	shape_file buildings_admin_shape_file <- shape_file(resources_dir + "buildings_admin.shp");
	geometry shape <- envelope(buildings_shape_file);

	reflex produce_pollutant {
		ask road {
			speed_coeff <- rnd(10)/10 ;
		}

	}

}

experiment exp1 {
	parameter "Number of cars" var: n_cars <- 0 min: 0 max: 500;
	parameter "Number of motorbikes" var: n_motorbikes <- 0 min: 0 max: 500;
	parameter "Number of greentaxi" var: n_taxi <- 0 min: 0 max: 1000;
	output synchronized: true {
		display main type: opengl background: #black axes: false {
		//			camera 'default' location: {581.6792, 1227.6974, 388.9891} target: {568.1048, 450.0203, 0.0};
			image ("../includes/bigger_map/hanoi.png");

			//			graphics toto {
			//				draw static_map_request;
			//			}
			//			species vehicle;
			//			species road position: {1300, 550, 0} size: {0.5, 0.5} {
			//				draw shape color: #darkgray;
			//			}
			//
			//			species taxi_random position: {1300, 550, 0} size: {0.5, 0.5} {
			//				if (current_road != nil) {
			//					point pos <- compute_position();
			//					draw circle(4) at: pos color: color;
			//				}
			//
			//			}
			species intersection aspect: base position: {1300, 550, 0} size: {0.5, 0.5};
			//			species natural;
			species road position: {0, 0, 0.001};
			species building aspect: border refresh: false;
			species car_random aspect: base;
			species motorbike_random aspect: base;
			species taxi_random aspect: base;
			//	species background;
			species progress_bar;
			species param_indicator;
			//		species line_graph;
			species line_graph_aqi position: {0, 0, -0.001};
			species indicator_health_concern_level;
			//			grid pollutant_grid elevation:pollution<0?0.0:pollution/10 transparency: 0.5 triangulation:true position:{0,0,-0.0001} ;
			//			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: palette([#white, #white, #orange, #orange, #red, #red, #red]) smooth: 2 position: {0, 0, -0.00001};
			//			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: scale([#white::0, #yellow::1, #orange::2, #red::6]) smooth: 1 position: {0, 0, -0.001};
			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1 position: {0, 0, -0.001};
		}

	}

}