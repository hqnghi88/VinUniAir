/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main

import "main2.gaml"

global {
	float step <- 1 #s;
	file icon <- file("../images/xanhsm.png");
	shape_file roads_shape_file <- shape_file("../includes/rrr.shp");
	//	shape_file dummy_roads_shape_file <- shape_file(resources_dir + "vinuniroad.shp");
	shape_file buildings_shape_file <- shape_file("../includes/buildingVin1.shp");
	//	shape_file road_cells_shape_file <- shape_file(resources_dir + "road_cells.shp");
	//	shape_file naturals_shape_file <- shape_file(resources_dir + "naturals.shp");
	//	shape_file buildings_admin_shape_file <- shape_file(resources_dir + "buildings_admin.shp");
	geometry shape <- envelope(buildings_shape_file);
	float xx_sc <- 1.0;
	float xx <- 3300.0;
	float yy <- 2000.0;
	float lx <- 30.0;
	float ly <- -630.0;
	float sub_scale <- 0.4;
	//	float map_scale_main <- 0.75;
	//	float map_main_y <- 5200.0;
	float WW <- 3.9;
	float HH <- 3.9;

	init {
	//		sizeCoeff <- 100;
		sizeCoeff <- 0.2;
		create progress_bar with:
		[x::0, y::yy + 180 * HH, width::250 * WW, height::20 * HH, max_val::(max_cars + max_bus + max_motorbikes), title::lb_rates_EG, left_label::"0%", right_label::"100%", scale::HH];
		create progress_bar with: [x::0, y::yy + 260 * HH, width::250 * WW, height::20 * HH, max_val::max_cars, title::lb_cars, left_label::"0%", right_label::"100%", scale::HH];
		create progress_bar with:
		[x::1200, y::yy + 180 * HH, width::250 * WW, height::20 * HH, max_val::max_motorbikes, title::lb_motobike, left_label::"0%", right_label::"100%", scale::HH];
		create progress_bar with: [x::1200, y::yy + 260 * HH, width::250 * WW, height::20 * HH, max_val::max_bus, title::lb_bus, left_label::"0%", right_label::"100%", scale::HH];
		//		create param_indicator with: [x::WW * 1300 * xx_sc + xx, y::20 * HH, size::30, name:: "Cars", value:: "0", with_box::false, width::200 * WW, height::20 * HH];
		//		create param_indicator with: [x::WW * 1300 * xx_sc + xx, y::50 * HH, size::30, name:: "Motorbikes", value:: "0", with_box::false, width::200 * WW, height::20 * HH];
		//		create param_indicator with: [x::WW * 1300 * xx_sc + xx, y::80 * HH, size::30, name:: "Green Taxi", value:: "0", with_box::false, width::200 * WW, height::20 * HH];

		//		create background with: [x::2450, y::1000, width::1250, height::1500, alpha::0.6];
		//		create line_graph with: [x::2500, y::1400, width::1200, height::1000, label::"Hourly AQI"];
		//		create indicator_health_concern_level with: [x::2800, y::2803, width::800, height::200];
		//		create param_indicator with: [x::22, y::ly + 60 * HH, size::30, name:: "Estimated realtime pollution", value:: "", with_box::false, width::500 * WW, height::10 * HH];
		create line_graph_aqi with: [x::680, y::ly + 170 * HH, width::300 * WW, height::110 * HH, label::"Hourly AQI", thick_axe::1, thick_line::5];
		create param_indicator with: [x::WW * lx + xx, y::ly + 70 * HH, size::30, name:: lb_Time, value:: "" + date("now"), with_box::false, width::500 * WW, height::20 * HH];
		create param_indicator with: [x::WW * lx + xx, y::ly + 110 * HH, size::30, name:: lb_Traffic_Incident, value:: "", with_box::false, width::200 * WW, height::20 * HH];
		create param_indicator with: [x::WW * lx + xx, y::ly + 500 * HH, size::30, name:: lb_AQI_update, value:: "", with_box::false, width::200 * WW, height::20 * HH];
		create api_loader;
		ask api_loader {
			do run_thread interval: 60 #second;
		}

	}

	string map_center <- "48.8566140,2.3522219";

	//	reflex produce_pollutant {
	//		ask road { 
	//			speed_coeff <- rnd(12);
	//		}
	//
	//	}

}

experiment expProj autorun: true {
	action _init_ {
		create simulation with: [max_cars::500, max_motorbikes::250, max_bus::250];
	}

	parameter "% of Electrical cars" var: n_cars <- 0 min: 0 max: max_cars;
	parameter "% of Electrical motorbikes" var: n_motorbikes <- 0 min: 0 max: max_motorbikes;
	parameter "% of Electrical bus" var: n_bus <- 0 min: 0 max: max_bus;
	output synchronized: true {
	//		layout #split parameters: false navigator: false editors: false consoles: false toolbars: false tray: false tabs: false controls: true;
		display "project" background: #black axes: false type: 3d 
		keystone: [{0.0,0.0,0.0},{0.0,1.0,0.0},{1.0,1.0,0.0},{0.9934502617256865,0.021782863139094277,0.0}]
		{
//			camera 'default' location: {1533.1738, 1295.5438, 2528.0513} target: {1533.1738, 1295.4997, 0.0};
			//			image ("../includes/ocplight.png") ;
			image ("../includes/vindark.png");	
			species road refresh: false position: {0, 0, 0.05};
			species building refresh: false;
			species car_random aspect: base position: {0, 0, 0.05};
			species dummy_car aspect: base position: {0, 0, 0.05};
			species motorbike_random aspect: base position: {0, 0, 0.05};
			species bus_random position: {0, 0, 0.05};

			mesh instant_heatmap scale: 0 above: 0.5 triangulation: true position: {0, 0, 0.01} transparency: 0.2 color: scale(zone_colors1) smooth: 0;
		}

	}

}

experiment exp2 autorun: false {

	action _init_ {
		create simulation with: [max_cars::500, max_motorbikes::250, max_bus::250];
	}

	parameter "Number of cars" var: n_cars <- 0 min: 0 max: max_cars;
	parameter "Number of motorbikes" var: n_motorbikes <- 0 min: 0 max: max_motorbikes;
	parameter "Number of bus" var: n_bus <- 0 min: 0 max: max_bus;
	output synchronized: false {
			layout #split parameters: false navigator: false editors: false consoles: false toolbars: false tray: false tabs: false controls: true;
//		display "project" type: 3d {
//			image ("../includes/ocplight.png");
//		}

		display main type: opengl background: #black axes: false {
			overlay position: {50 #px, 50 #px} size: {1 #px, 1 #px} background: #black border: #black rounded: false {
			//for each possible type, we draw a square with the corresponding color and we write the name of the type
			//				draw "Estimated pollution based on realtime traffic incident and AQ sensors" at: {0, 0} anchor: #top_left color: #white font: title;
				float y <- 10 #px;
				draw rectangle(40 #px, 160 #px) at: {20 #px, y + 60 #px} wireframe: true color: #white;
				loop p over: reverse(pollutions.pairs) {
					draw square(40 #px) at: {20 #px, y} color: rgb(p.key, 1.0);
					draw p.value at: {60 #px, y} anchor: #left_center color: #white font: text;
					y <- y + 40 #px;
				}

				y <- y + 340 #px;
				draw "Icons" at: {0, y} anchor: #top_left color: #white font: title;
				y <- y + 40 #px;
				//				draw rectangle(40 #px, 120 #px) at: {20 #px, y + 40 #px} wireframe: true color: #white;
				loop p over: legends.pairs {
					draw legends_geom4[p.value] at: {20 #px, y} color: rgb(p.key, 0.8);
					draw p.value at: {60 #px, y} anchor: #left_center color: #white font: text;
					y <- y + 40 #px;
				}

				draw "Estimated realtime pollution" at: {220 #px, -20 #px} color: #white font: font(32);
				ask line_graph_aqi {
					do drawing;
				}
			
			}

			//			light #ambient intensity: 256;
			camera 'default' location: {2213.9071, 1427.288, 4231.7434} target: {2213.9071, 1427.288, 0.0};
			//
			//
			//
			//
			//
			image ("../includes/vindark.png") position: {3440, 0, -0.01} size: {sub_scale, sub_scale};
			species building refresh: false position: {3440, 0, 0} size: {sub_scale, sub_scale};
			species traffic_incident position: {3440, 0, 0} size: {sub_scale, sub_scale};
			//
			//
			//
			//
			//
			image ("../includes/vindark.png") position: {3440, 1500, -0.01} size: {sub_scale, sub_scale};
			species building refresh: false position: {3440, 1500, 0} size: {sub_scale, sub_scale};
			species AQI position: {3440, 1500, 0.01} size: {sub_scale, sub_scale};
			//		
			//
			//
			//
			//
			//						species road refresh: false;
			species building refresh: false;
			species car_random aspect: base;
			species dummy_car aspect: base;
			species motorbike_random aspect: base;
			species bus_random {
			//				dist <- 1.0;
			//				point pos <- compute_position();
				draw squircle(50 * sizeCoeff, 6 * sizeCoeff) texture: icon rotate: 0 depth: 0.5 * sizeCoeff;
				//				draw circle(10) at: pos rotate: heading depth: 1 * sizeCoeff;
			}

			mesh instant_heatmap scale: 4 above: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1;
			//		
			//
			//
			//
			//
			species progress_bar position: {0, 0, 0.0001};
			//			species line_graph_aqi position: {0, 0, 0.01};
			species param_indicator position: {0, 0, 0.01};
			event #mouse_down {
				if (#user_location overlaps first(progress_bar where (each.title = lb_cars)).bound) {
					point p <- #user_location;
					geometry pp <- first(progress_bar where (each.title = lb_cars)).bound;
					n_cars <- int(max_cars * ((p.x - ((pp.location.x - pp.width / 2))) / (pp.width)));
					write n_cars;
				}

				if (#user_location overlaps first(progress_bar where (each.title = lb_motobike)).bound) {
					point p <- #user_location;
					geometry pp <- first(progress_bar where (each.title = lb_motobike)).bound;
					n_motorbikes <- int(max_motorbikes * ((p.x - ((pp.location.x - pp.width / 2))) / (pp.width)));
				}

				if (#user_location overlaps first(progress_bar where (each.title = lb_bus)).bound) {
					point p <- #user_location;
					geometry pp <- first(progress_bar where (each.title = lb_bus)).bound;
					n_bus <- int(max_bus * ((p.x - ((pp.location.x - pp.width / 2))) / (pp.width)));
				}

			}

		}

	}

}
//
//experiment estim autorun: false {
//
//	action _init_ {
//		create simulation with: [tttt::0];
//	}
//
//	output synchronized: false {
//		layout #split parameters: false navigator: false editors: false consoles: false toolbars: false tray: false tabs: false controls: true;
//		display main type: 3d background: #black axes: false {
////			overlay position: {50 #px, 50 #px} size: {1 #px, 1 #px} background: #black border: #black rounded: false {
////			//for each possible type, we draw a square with the corresponding color and we write the name of the type
////			//				draw "Estimated pollution based on realtime traffic incident and AQ sensors" at: {0, 0} anchor: #top_left color: #white font: title;
////				float y <- 50 #px;
////				draw rectangle(40 #px, 160 #px) at: {20 #px, y + 60 #px} wireframe: true color: #white;
////				loop p over: reverse(pollutions.pairs) {
////					draw square(40 #px) at: {20 #px, y} color: rgb(p.key, 1.0);
////					draw p.value at: {60 #px, y} anchor: #left_center color: #white font: text;
////					y <- y + 40 #px;
////				}
////
////			}
////
////			//			light #ambient intensity: 256;
//////			camera 'default' location: {23714.1541, 15022.4038, 37277.7705} target: {23714.1541, 15021.7533, 0.0}; //
////			//
////			//
////			//
////			image ("../includes/vindark.png") position: {lx * WW * xx_sc + xx, 100 * HH, -0.01} size: {0.5, 0.5};
////			species building aspect: border refresh: false position: {lx * WW * xx_sc + xx, 100 * HH, 0} size: {0.5, 0.5};
////			species traffic_incident position: {lx * WW * xx_sc + xx, 100 * HH, 0.01} size: {0.5, 0.5};
////			//
////			//
////			//
////			//
////			//
////			image ("../includes/vindark.png") position: {lx * WW * xx_sc + xx, 590 * HH, -0.01} size: {0.5, 0.5};
////			species building aspect: border refresh: false position: {lx * WW * xx_sc + xx, 590 * HH, 0} size: {0.5, 0.5};
////			species AQI position: {lx * WW * xx_sc + xx, 590 * HH, 0.01} size: {0.5, 0.5};
//			//		
//			//
//			//
//			//
//			//
//			image ("../includes/vindark.png") position: {0, 0, -0.0001};
//			species building refresh: false; 
//			species motorbike_random aspect: base;
//			mesh instant_heatmap scale: 1 above: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1;
////			species line_graph_aqi position: {0, 0, 0.01};
////			species param_indicator position: {0, 0, 0.01};
//		}
//
//	}
//
//}