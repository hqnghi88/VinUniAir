/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main

import "agents/traffic.gaml"
import "agents/pollution.gaml"
import "agents/visualization.gaml"

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
		create intersection from: intersect0_shape_file with: [is_traffic_signal::(read("TYPE") = true)] {
					is_traffic_signal <- false;
		//				with: [is_traffic_signal::(read("type") = "traffic_signals")] {
			time_to_change <- traffic_light_interval / 2 + rnd(traffic_light_interval);
		}

		create road from: roads_shape_file {
		// Create a reverse road if the road is not oneway
			num_lanes <- 4;//rnd(4, 6);
			// Create another road in the opposite direction
			create road {
				num_lanes <- myself.num_lanes;
				shape <- polyline(reverse(myself.shape.points));
				maxspeed <- myself.maxspeed;
				linked_road <- myself;
				myself.linked_road <- self;
			}

		}

		map edge_weights <- road as_map (each::each.shape.perimeter);
		road_network <- as_driving_graph(road, intersection) with_weights edge_weights;

		//		geometry road_geometry <- union(road accumulate (each.shape));
		non_deadend_nodes <- intersection where !empty(each.roads_out);
		// Initialize the traffic lights
		ask intersection {
			do initialize;
		}

		// Additional visualization
		create building from: buildings_shape_file {
			depth <- (rnd(100) / 100) * (rnd(100) / 100) * (rnd(100) / 100 * 10) * 5 + 10;
			texture <- textures[rnd(9)];
		}
 
	}

	reflex update_time {
		int h <- current_date.hour;
		int m <- current_date.minute;
		int s <- current_date.second;
		string hh <- ((h < 10) ? "0" : "") + string(h);
		string mm <- ((m < 10) ? "0" : "") + string(m);
		string ss <- ((s < 10) ? "0" : "") + string(s);
		string t <- hh + ":" + mm + ":" + ss;
		ask (param_indicator where (each.name = "Time")) {
			do update(t);
		}

	}

	reflex calculate_aqi when: every(refreshing_rate_plot) { //every(1 #minute) {
		float aqi <- max(instant_heatmap);
		ask line_graph_aqi {
			do update(aqi * 10);
		}
		//		 ask indicator_health_concern_level {
		//		 	do update(aqi);
		//		 }
	}

	action update_vehicle_population (string type, int delta) {
		if (type = "motorbike") {
			list<motorbike_random> vehicles <- list(motorbike_random);
			if (delta < 0) {
				ask -delta among motorbike_random {
					do die;
				}

			} else {
			//				create motorbike_random number: delta;	
				create motorbike_random number: delta with: [type:: "motorbike"];
			}

		}

		if (type = "car") {
		//				create car_random number: delta;			
			list<car_random> vehicles <- list(car_random);
			if (delta < 0) {
				ask -delta among car_random {
					do die;
				}

			} else {
				create car_random number: delta with: [type:: "car"];
			}

		}

		if (type = "taxi") {
		//				create car_random number: delta;			
			list<taxi_random> vehicles <- list(taxi_random);
			if (delta < 0) {
				ask -delta among taxi_random {
					do die;
				}

			} else {
				create taxi_random number: delta with: [type:: "taxi"];
			}

		}

	}

	reflex update_car_population when: n_cars != n_cars_prev {
		int delta_cars <- n_cars - n_cars_prev;
		do update_vehicle_population("car", delta_cars);
		ask first(progress_bar where (each.title = "Cars")) {
			do update(float(n_cars));
		}

		n_cars_prev <- n_cars;
	}

	reflex update_motorbike_population when: n_motorbikes != n_motorbikes_prev {
		int delta_motorbikes <- n_motorbikes - n_motorbikes_prev;
		do update_vehicle_population("motorbike", delta_motorbikes);
		ask first(progress_bar where (each.title = "Motorbikes")) {
			do update(float(n_motorbikes));
		}

		n_motorbikes_prev <- n_motorbikes;
	}

	reflex update_taxi_population when: n_taxi != n_taxi_prev {
		int delta_taxi <- n_taxi - n_taxi_prev;
		do update_vehicle_population("taxi", delta_taxi);
		ask first(progress_bar where (each.title = "Green Taxi")) {
			do update(float(n_taxi));
		}

		n_taxi_prev <- n_taxi;
	}

	//	reflex update_road_scenario when: road_scenario != road_scenario_prev {
	//		switch road_scenario {
	//			match 0 {
	//				open_roads <- list(road);
	//			}
	//
	//			match 1 {
	//				open_roads <- road where !each.s1_closed;
	//			}
	//
	//			match 2 {
	//				open_roads <- road where !each.s2_closed;
	//			}
	//
	//		}
	//
	//		list<road> closed_roads <- road - open_roads;
	//		ask open_roads {
	//			closed <- false;
	//		}
	//
	//		ask closed_roads {
	//			closed <- true;
	//		}
	//
	//		map<road, float> road_weights <- open_roads as_map (each::each.shape.perimeter);
	//		graph new_road_network <- as_edge_graph(open_roads) with_weights road_weights;
	//		ask vehicle {
	//			recompute_path <- true;
	//		}
	//
	//		road_network <- new_road_network;
	//		road_scenario_prev <- road_scenario;
	//	}

	//	reflex create_congestions {
	//		float start <- machine_time;
	//		ask open_roads {
	//			list<vehicle> vehicles_on_road <- vehicle at_distance 1;
	//			int n_cars_on_road <- vehicles_on_road count (each.type = "car");
	//			int n_motorbikes_on_road <- vehicles_on_road count (each.type = "motorbike");
	//			do update_speed_coeff(n_cars_on_road, n_motorbikes_on_road);
	//		}
	//
	//		map<float, float> road_weights <- open_roads as_map (each::(each.shape.perimeter / each.speed_coeff));
	//		road_network <- road_network with_weights road_weights;
	//		time_create_congestions <- machine_time - start;
	//	}
	matrix<float> mat_diff <- matrix([[1 / 20, 1 / 20, 1 / 20], [1 / 20, 3 / 5 * pollutant_decay_rate, 1 / 20], [1 / 20, 1 / 20, 1 / 20]]);
	//
	//	reflex produce_pollutant {
	//	// Absorb pollutants emitted by vehicles
	//		ask building parallel: true {
	//			aqi <- 0.0;
	//		}
	//
	//		ask road_cell {
	////			write self;
	//			list<car_random> vehicles_in_cell <- car_random inside self;
	//			loop v over: vehicles_in_cell {
	//				if (is_number(v.real_speed)) {
	//					float dist_traveled <- v.real_speed * step / #km;
	//					co <- co + dist_traveled * EMISSION_FACTOR[v.type]["CO"];
	//					nox <- nox + dist_traveled * EMISSION_FACTOR[v.type]["NOx"];
	//					so2 <- so2 + dist_traveled * EMISSION_FACTOR[v.type]["SO2"];
	//					pm <- pm + dist_traveled * EMISSION_FACTOR[v.type]["PM"];
	//				}
	//
	//			}
	//
	//			//			time_absorb_pollutants <- time_absorb_pollutants + (machine_time - start);
	//
	//			// Diffuse pollutants to neighbor cells
	//			ask neighbors {
	//				self.co <- self.co + pollutant_diffusion * myself.co;
	//				self.nox <- self.nox + pollutant_diffusion * myself.nox;
	//				self.so2 <- self.so2 + pollutant_diffusion * myself.so2;
	//				self.pm <- self.pm + pollutant_diffusion * myself.pm;
	//			}
	//
	//			co <- co * (1 - pollutant_diffusion * length(neighbors));
	//			nox <- nox * (1 - pollutant_diffusion * length(neighbors));
	//			so2 <- so2 * (1 - pollutant_diffusion * length(neighbors));
	//			pm <- pm * (1 - pollutant_diffusion * length(neighbors));
	//
	//			// Decay pollutants
	//			co <- pollutant_decay_rate * co;
	//			nox <- pollutant_decay_rate * nox;
	//			so2 <- pollutant_decay_rate * so2;
	//			pm <- pollutant_decay_rate * pm;
	//			//			time_diffuse_pollutants <- time_diffuse_pollutants + (machine_time - start);
	//			list<building> buildings <- list<building>(self.affected_buildings);
	//			ask buildings {
	//				self.aqi <- self.aqi + myself.aqi;
	//			}
	//
	//		}
	//
	//	}

	//	reflex benchmark when: benchmark and every(5 #cycle) {
	//		write "Vehicles move: " + time_vehicles_move;
	//		write "Create congestions: " + time_create_congestions;
	//		write "Absorb pollutants: " + time_absorb_pollutants;
	//		write "Diffuse pollutants: " + time_diffuse_pollutants;
	//		
	//		time_vehicles_move <- 0.0;
	//		time_absorb_pollutants <- 0.0;
	//		time_diffuse_pollutants <- 0.0;
	//	}
	float decrease_coeff <- 0.99;
	int size <- 150;
	field instant_heatmap <- field(size, size);

	reflex diff {
			diffuse "phero" on: instant_heatmap matrix: mat_diff;
//		diffuse "trial" on: instant_heatmap;
	}

	reflex update {
//			instant_heatmap[] <- instant_heatmap[] * decrease_coeff;
//			instant_heatmap[] <-0;
		ask car_random + motorbike_random + taxi_random {
			instant_heatmap[location] <- instant_heatmap[location] + self.aqh / 100;
		}

	}

}

//grid pollutant_grid height: 100 width: 100 neighbors: 8 /*schedules: active_cells*/ {
//	rgb color <- #black;
//	bool active <- false;
//	float pollution;
//
//	reflex pollution_increase when: active {
//		list<vehicle> people_on_cell <- vehicle overlapping self;
//		pollution <- pollution + sum(people_on_cell accumulate (each.get_pollution()));
//	}
//
//	reflex diffusion {
//		ask neighbors {
//			pollution <- pollution + 0.05 * myself.pollution;
//		}
//
//		pollution <- pollution * (1 - 8 * 0.05);
//	}
//
//	reflex update {
//		pollution <- pollution * decrease_coeff;
//		color <- rgb(255 * pollution/10, 0, 0);
//		color<-palette([ #white, #white, #orange, #orange, #red, #red, #red])[int(min(pollution,MAX_P)*7/MAX_P)mod 7];
//	} 
//}
experiment exp virtual:true {
	parameter "Number of cars" var: n_cars <- 0 min: 0 max: 500;
	parameter "Number of motorbikes" var: n_motorbikes <- 0 min: 0 max: 500;
	parameter "Number of greentaxi" var: n_taxi <- 0 min: 0 max: 1000;
	output synchronized: true {
		display main type: opengl background: #black axes: false {
		//			camera 'default' location: {581.6792, 1227.6974, 388.9891} target: {568.1048, 450.0203, 0.0};
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
			//			grid pollutant_grid elevation:pollution<0?0.0:pollution/10 transparency: 0.5 triangulation:true position:{0,0,-0.0001} ;
			//			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: palette([#white, #white, #orange, #orange, #red, #red, #red]) smooth: 2 position: {0, 0, -0.00001};
//			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: scale([#white::0, #yellow::1, #orange::2, #red::6]) smooth: 1 position: {0, 0, -0.001};
			mesh instant_heatmap scale: 1 triangulation: true transparency: 0.5 color: scale(zone_colors1) smooth: 1 position: {0, 0, -0.001};
		}

	}

}