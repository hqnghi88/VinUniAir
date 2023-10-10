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
		//		create progress_bar with: [x::WW * 1300, y::20 * HH, width::250 * WW, height::20 * HH, max_val::500, title::"Cars", left_label::"0", right_label::"Max", scale::HH];
		//		create progress_bar with: [x::WW * 1300, y::100 * HH, width::250 * WW, height::20 * HH, max_val::500, title::"Motorbikes", left_label::"0", right_label::"Max", scale::HH];
		//		create progress_bar with: [x::WW * 1300, y::180 * HH, width::500 * WW, height::20 * HH, max_val::1000, title::"Green Taxi", left_label::"0", right_label::"Max", scale::HH];
		create param_indicator with: [x::WW * 1300, y::20 * HH, size::30, name:: "Cars", value:: "0", with_box::false, width::200 * WW, height::20 * HH];
		create param_indicator with: [x::WW * 1300, y::50 * HH, size::30, name:: "Motorbikes", value:: "0", with_box::false, width::200 * WW, height::20 * HH];
		create param_indicator with: [x::WW * 1300, y::80 * HH, size::30, name:: "Green Taxi", value:: "0", with_box::false, width::200 * WW, height::20 * HH];

		//		create param_indicator with: [x::1300, y::850, size::22, name::"Road scenario", value::"No blocked roads", with_RT::true];
		//		create param_indicator with: [x::1300, y::1050, size::22, name::"Display mode", value::"Traffic"];

		//		create background with: [x::2450, y::1000, width::1250, height::1500, alpha::0.6];
		//		create line_graph with: [x::2500, y::1400, width::1200, height::1000, label::"Hourly AQI"];
		create line_graph_aqi with: [x::WW * 1300, y::100 * HH, width::500 * WW, height::100 * HH, label::"Hourly AQI", thick::50];
		//		create indicator_health_concern_level with: [x::2800, y::2803, width::800, height::200];
		create param_indicator with: [x::WW * 1300, y::260 * HH, size::30, name:: "Time", value:: "00:00:00", with_box::false, width::500 * WW, height::20 * HH];
		create param_indicator with: [x::WW * 1300, y::560 * HH, size::30, name:: "Traffic Incident updated", value:: "00:00:00", with_box::false, width::200 * WW, height::20 * HH];
		create param_indicator with: [x::WW * 1300, y::900 * HH, size::30, name:: "AQI updated", value:: "00:00:00", with_box::false, width::200 * WW, height::20 * HH];
		create api_loader ;
		ask api_loader{
			
		do run_thread interval:60#second;
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

species api_loader skills:[thread]{
	float start <- machine_time;
	float end <- machine_time;

	//counting down
	action thread_action { 
		
			do loadtraffic;
			do loadAQ;
	}
	
	action loadAQ {
		ask AQI {
			do die;
		}

		//		write "https://api.waqi.info/v2/map/bounds?token=3e88ec52a139b2da87ef8a5e2215c21ad16ea263&latlng=21.099234882428494,105.71216583251955,20.96464560107569,105.99266052246094";
		json_file
		sss <- json_file("https://api.waqi.info/v2/map/bounds?token=3e88ec52a139b2da87ef8a5e2215c21ad16ea263&latlng=21.099234882428494,105.71216583251955,20.96464560107569,105.99266052246094");
		map<string, unknown> c <- sss.contents;
		list cells <- c["data"];
		//		write cells;
		loop cc over: cells {
			AQI tt;
			if (cc["lat"] != nil) {
				point pp <- {float(cc["lat"]), float(cc["lon"])};
				create AQI {
					tt <- self;
					aqi <- float(cc["aqi"]);
					//					location<-(pp   CRS_transform("EPSG:32648")).location;
					location <- to_GAMA_CRS({pp.y, pp.x}, "4326").location;
				}
				//				write pp;
			}

		}

		ask (param_indicator where (each.name = "AQI updated")) {
			do update("" + date("now"));
		}

	}

	action loadtraffic {
		geometry loc <- (world.shape CRS_transform ("EPSG:4326"));
		map_center <- "" + loc.points[0].y + "," + loc.points[0].x + "," + loc.points[2].y + "," + loc.points[2].x;
		//		write map_center;
		ask traffic_incident {
			do die;
		}

		//				write "https://dev.virtualearth.net/REST/v1/Traffic/Incidents/" + map_center + "?includeJamcidents=true&key=AvZ5t7w-HChgI2LOFoy_UF4cf77ypi2ctGYxCgWOLGFwMGIGrsiDpCDCjliUliln";
		json_file
		sss <- json_file("https://dev.virtualearth.net/REST/v1/Traffic/Incidents/" + map_center + "?includeJamcidents=true&key=AvZ5t7w-HChgI2LOFoy_UF4cf77ypi2ctGYxCgWOLGFwMGIGrsiDpCDCjliUliln");
		map<string, unknown> c <- sss.contents;
		list cells <- c["resourceSets"]["resources"];
		loop mm over: cells {
			loop mmm over: mm as list {
				map<string, unknown> cc <- mmm;
				traffic_incident tt;
				if (cc["point"] != nil) {
					point pp <- cc["point"]["coordinates"];
					geometry pcc <- square(100) at_location (to_GAMA_CRS({pp.y, pp.x}, "4326").location);
					//					write (building  overlapping pcc);
					if (length(building overlapping pcc) > 0) {
						create traffic_incident {
							description <- cc["description"];
							tt <- self;
							//					location<-(pp   CRS_transform("EPSG:32648")).location;
							location <- to_GAMA_CRS({pp.y, pp.x}, "4326").location;
						}

					}

					//				write pp;
				}

				if (cc["toPoint"] != nil and tt != nil) {
					point pp <- cc["toPoint"]["coordinates"];
					point ppp <- to_GAMA_CRS({pp.y, pp.x}, "4326").location;
					tt.shape <- line([tt.location, ppp]);
				}

			}

		}

		//		date curr <- date("now");
		//		int h <- current_date.hour;
		//		int m <- current_date.minute;
		//		int s <- current_date.second;
		//		string hh <- ((h < 10) ? "0" : "") + string(h);
		//		string mm <- ((m < 10) ? "0" : "") + string(m);
		//		string ss <- ((s < 10) ? "0" : "") + string(s);
		//		string t <- hh + ":" + mm + ":" + ss;
		ask (param_indicator where (each.name = "Traffic Incident updated")) {
			do update("" + date("now"));
		}

	}

//	reflex sss {
//		if (end - start > 600) {
////			do loadtraffic;
////			do loadAQ;
//			loop times:100000000{}
//			start <- machine_time;
//		}
//
//		end <- machine_time;
//	}

}

experiment exp1  autorun:true{ 
	parameter "Number of cars" var: n_cars <- 0 min: 0 max: 1000;
	parameter "Number of motorbikes" var: n_motorbikes <- 0 min: 0 max: 1000;
	parameter "Number of greentaxi" var: n_taxi <- 10 min: 0 max: 1000;
	output synchronized: false {
		display main type: opengl background: #black axes: false {
			camera 'default' location: {22562.0664, 12690.6195, 32387.3272} target: {22562.0664, 12690.0543, 0.0};
//			image ("../includes/bigger_map/hanoi.png") position: {0, 0, -0.001};

			//			graphics toto {
			//				draw static_map_request;
			//			}
			//			species vehicle;
			species road position: {1300 * WW, 200 * HH, 0} size: {0.4, 0.4} {
				draw shape color: #darkgray - 100;
			}

			species traffic_incident position: {1300 * WW, 200 * HH, 0.01} size: {0.4, 0.4};
			species road position: {1300 * WW, 550 * HH, 0} size: {0.4, 0.4} {
				draw shape color: #darkgray - 100;
			}

			species AQI position: {1300 * WW, 550 * HH, 0.01} size: {0.4, 0.4};
			//			species taxi_random position: {1300 * WW, 550 * HH, 0} size: {0.7, 0.7} {
			//				point pos <- compute_position();
			//				draw squircle(200, 6) texture: icon size: 500 at: pos rotate: 0 depth: 1 * sizeCoeff;
			//				//				draw circle(10) at: pos rotate: heading depth: 1 * sizeCoeff;
			//			}
			//			species natural;
			species road;
			species building aspect: border refresh: false position: {0, 0, 0.001};
			species car_random aspect: base;
			species dummy_car aspect: base;
			species motorbike_random aspect: base;
			species taxi_random {
				point pos <- compute_position();
				draw squircle(500, 6) texture: icon at: pos rotate: 0 depth: 1 * sizeCoeff;
				//				draw circle(10) at: pos rotate: heading depth: 1 * sizeCoeff;
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