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
	shape_file roads_shape_file <- shape_file("../includes/bigger_map/oads_.shp");
	//	shape_file dummy_roads_shape_file <- shape_file(resources_dir + "vinuniroad.shp");
	shape_file buildings_shape_file <- shape_file("../includes/bigger_map/hanoi2.shp");
	//	shape_file road_cells_shape_file <- shape_file(resources_dir + "road_cells.shp");
	//	shape_file naturals_shape_file <- shape_file(resources_dir + "naturals.shp");
	//	shape_file buildings_admin_shape_file <- shape_file(resources_dir + "buildings_admin.shp");
	geometry shape <- envelope(buildings_shape_file) + 2000;
	float xx_sc <- 1.0;
	float xx <- -5000.0;
	float yy <- 20000.0;
	float lx<-900.0;
	float WW <- world.shape.width / 1184.1165564209223;
	float HH <- world.shape.height / 929.0766558628529;

	init {
		sizeCoeff <- 100;
		create progress_bar with:
		[x::WW * 80 * xx_sc + xx, y::yy + -60 * HH, width::250 * WW, height::20 * HH, max_val::(max_cars + max_bus + max_motorbikes), title::lb_rates_EG, left_label::"0%", right_label::"100%", scale::HH];
		create progress_bar with:
		[x::WW * 80 * xx_sc + xx, y::yy + 20 * HH, width::250 * WW, height::20 * HH, max_val::max_cars, title::lb_cars, left_label::"0%", right_label::"100%", scale::HH];
		create progress_bar with:
		[x::WW * 80 * xx_sc + xx, y::yy + 100 * HH, width::250 * WW, height::20 * HH, max_val::max_motorbikes, title::lb_motobike, left_label::"0%", right_label::"100%", scale::HH];
		create progress_bar with:
		[x::WW * 80 * xx_sc + xx, y::yy + 180 * HH, width::250 * WW, height::20 * HH, max_val::max_bus, title::lb_bus, left_label::"0%", right_label::"100%", scale::HH];
		//		create param_indicator with: [x::WW * 1300 * xx_sc + xx, y::20 * HH, size::30, name:: "Cars", value:: "0", with_box::false, width::200 * WW, height::20 * HH];
		//		create param_indicator with: [x::WW * 1300 * xx_sc + xx, y::50 * HH, size::30, name:: "Motorbikes", value:: "0", with_box::false, width::200 * WW, height::20 * HH];
		//		create param_indicator with: [x::WW * 1300 * xx_sc + xx, y::80 * HH, size::30, name:: "Green Taxi", value:: "0", with_box::false, width::200 * WW, height::20 * HH];

		//		create background with: [x::2450, y::1000, width::1250, height::1500, alpha::0.6];
		//		create line_graph with: [x::2500, y::1400, width::1200, height::1000, label::"Hourly AQI"];
		create line_graph_aqi with: [x::WW * 200 * xx_sc + xx, y::40 * HH, width::300 * WW, height::110 * HH, label::"Hourly AQI", thick::50];
		//		create indicator_health_concern_level with: [x::2800, y::2803, width::800, height::200];
		create param_indicator with: [x::WW * lx * xx_sc + xx, y::20 * HH, size::30, name:: lb_Time, value:: "" + date("now"), with_box::false, width::500 * WW, height::20 * HH];
		create param_indicator with: [x::WW * lx * xx_sc + xx, y::60 * HH, size::30, name:: lb_Traffic_Incident, value:: "", with_box::false, width::200 * WW, height::20 * HH];
		create param_indicator with: [x::WW * lx * xx_sc + xx, y::460 * HH, size::30, name:: lb_AQI_update, value:: "", with_box::false, width::200 * WW, height::20 * HH];
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

species api_loader skills: [thread] {
	float start <- machine_time;
	float end <- machine_time;

	//counting down
	action thread_action {
		try {
			do loadtraffic;
			do loadAQ;
		}

		catch {
			write ".";
		}

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

		//		ask (param_indicator where (each.name = lb_AQI_update)) {
		//			do update("" + date("now"));
		//		}

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
		//		ask (param_indicator where (each.name = lb_Traffic_Incident)) {
		//			do update("" + date("now"));
		//		}

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

experiment exp2 autorun: true {

//	action _init_ {
//		create simulation with: [xx_sc::1, xx::0];
//	}
	parameter "Number of cars" var: n_cars <- 0 min: 0 max: max_cars;
	parameter "Number of motorbikes" var: n_motorbikes <- 0 min: 0 max: max_motorbikes;
	parameter "Number of bus" var: n_bus <- 0 min: 0 max: max_bus;
	output synchronized: false {
		layout #split parameters: false navigator: false editors: false consoles: false toolbars: false tray: false tabs: false controls: true;
		display main type: opengl background: #black axes: false {
			overlay position: {50 #px, 50 #px} size: {1 #px, 1 #px} background: #black border: #black rounded: false {
			//for each possible type, we draw a square with the corresponding color and we write the name of the type
				draw "Estimated pollution based on realtime traffic incident and AQ sensors" at: {0, 0} anchor: #top_left color: #white font: title;
				float y <- 50 #px;
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
					draw legends_geom1[p.value] at: {20 #px, y} color: rgb(p.key, 0.8);
					draw p.value at: {60 #px, y} anchor: #left_center color: #white font: text;
					y <- y + 40 #px;
				}

			}

			light #ambient intensity: 256;
			camera 'default' location: {19640.4799, 13233.1794, 33812.0367} target: {19640.4799, 13232.5893, 0.0};
			image ("../includes/bigger_map/hanoi.png") position: {0, 0, -0.001};

			//			graphics toto {
			//				draw static_map_request;
			//			}
			//			species vehicle;
			species road position: {1300 * WW * xx_sc + xx, 200 * HH, 0} size: {0.4, 0.4} {
				draw shape color: #darkgray - 100;
			}

			species traffic_incident position: {1300 * WW * xx_sc + xx, 200 * HH, 0.01} size: {0.4, 0.4};
			species road position: {1300 * WW * xx_sc + xx, 550 * HH, 0} size: {0.4, 0.4} {
				draw shape color: #darkgray - 100;
			}

			species AQI position: {1300 * WW * xx_sc + xx, 550 * HH, 0.01} size: {0.4, 0.4};
			species road;
			species building aspect: border refresh: false position: {0, 0, 0.001};
			species car_random aspect: base;
			species dummy_car aspect: base;
			species motorbike_random aspect: base;
			species bus_random {
				point pos <- compute_position();
				draw squircle(50, 6) texture: icon at: pos rotate: 0 depth: 1 * sizeCoeff;
				//				draw circle(10) at: pos rotate: heading depth: 1 * sizeCoeff;
			}

			mesh instant_heatmap scale: 1 above: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1 position: {0, 0, 0.001};
			species progress_bar;
			species param_indicator;
			species line_graph_aqi position: {0, 0, -0.001};
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

experiment estim autorun: true {

	action _init_ {
		create simulation with: [tttt::0];
	}

	output synchronized: false {
		layout #split parameters: false navigator: false editors: false consoles: false toolbars: false tray: false tabs: false controls: true;
		display main type: opengl background: #black axes: false {
			overlay position: {50 #px, 50 #px} size: {1 #px, 1 #px} background: #black border: #black rounded: false {
			//for each possible type, we draw a square with the corresponding color and we write the name of the type
				draw "Estimated pollution based on realtime traffic incident and AQ sensors" at: {0, 0} anchor: #top_left color: #white font: title;
				float y <- 50 #px;
				draw rectangle(40 #px, 160 #px) at: {20 #px, y + 60 #px} wireframe: true color: #white;
				loop p over: reverse(pollutions.pairs) {
					draw square(40 #px) at: {20 #px, y} color: rgb(p.key, 1.0);
					draw p.value at: {60 #px, y} anchor: #left_center color: #white font: text;
					y <- y + 40 #px;
				}

//				y <- y + 340 #px;
//				draw "Icons" at: {0, y} anchor: #top_left color: #white font: title;
//				y <- y + 40 #px;
//				//				draw rectangle(40 #px, 120 #px) at: {20 #px, y + 40 #px} wireframe: true color: #white;
//				loop p over: legends.pairs {
//					draw legends_geom1[p.value] at: {20 #px, y} color: rgb(p.key, 0.8);
//					draw p.value at: {60 #px, y} anchor: #left_center color: #white font: text;
//					y <- y + 40 #px;
//				}

			}

			light #ambient intensity: 256;
			camera 'default' location: {19640.4799, 13233.1794, 33812.0367} target: {19640.4799, 13232.5893, 0.0};

			//			graphics toto {
			//				draw static_map_request;
			//			}
			//			species vehicle;
			image ("../includes/bigger_map/hanoi_dark.png") position: {lx * WW * xx_sc + xx, -100 * HH, -0.01} size: {0.65, 0.65};
			species building aspect: border refresh: false  position: {lx * WW * xx_sc + xx, -100 * HH, 0} size: {0.65, 0.65} ;
			species traffic_incident position: {lx * WW * xx_sc + xx, -100 * HH, 0.01} size: {0.65, 0.65};

			
			

			image ("../includes/bigger_map/hanoi_dark.png") position: {lx * WW * xx_sc + xx, 400 * HH, -0.01} size: {0.65, 0.65};
			species building aspect: border refresh: false  position: {lx * WW * xx_sc + xx, 400 * HH, 0} size: {0.65, 0.65};
			species AQI position: {lx * WW * xx_sc + xx, 400 * HH, 0.01} size: {0.65, 0.65};
			//			species road;
			
			image ("../includes/bigger_map/hanoi_dark.png") position: {-4000, 5200, -0.01} size: {0.75, 0.75} ;
			species building aspect: border refresh: false  position: {-4000, 5200, -0.01} size: {0.75, 0.75} ;			
			mesh instant_heatmap scale: 1 above: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1 position: {-2000, 3000, -0.01}   size: {0.75, 0.75};
			
			species line_graph_aqi position: {0, 0, -0.001};
			species param_indicator;
		}

	}

}