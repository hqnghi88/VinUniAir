/***
* Name: traffic
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model traffic

import "../global_vars.gaml"

global {
	float time_vehicles_move;
	int nb_recompute_path;
	float lane_width <- 1.7;
	list<intersection> non_deadend_nodes;
}

species road schedules: [] skills: [road_skill] {
	rgb color <- #white;
	string type;
	bool oneway;
	bool s1_closed;
	bool s2_closed;
	bool closed;
	float capacity <- 1 + shape.perimeter / 30;
	float speed_coeff <- 1.0 min: 0.1;

	action update_speed_coeff (int n_cars_on_road, int n_motorbikes_on_road) {
		speed_coeff <- (n_cars_on_road + n_motorbikes_on_road <= capacity) ? 1 : exp(-(n_motorbikes_on_road + 4 * n_cars_on_road) / capacity);
	}

	aspect default {
	//		if (display_mode = 0) {
	//			if (closed) {
	//				draw shape + 50 color: palet[CLOSED_ROAD_TRAFFIC];
	//			} else {
		draw shape + 2 / (speed_coeff) color: (speed_coeff = 1.0) ? palet[NOT_CONGESTED_ROAD] : palet[CONGESTED_ROAD] /*end_arrow: 10*/;
		//			}
		//
		//		} else {
		//			if (closed) {
		//				draw shape + 50 color: palet[CLOSED_ROAD_POLLUTION];
		//			}
		//
		//		}

		//		if (closed) {
		//			draw shape + 5 color: palet[CLOSED_ROAD];
		//		} else if (display_mode = 0) {
		//			draw shape+2/(speed_coeff) color: (speed_coeff=1.0) ? palet[NOT_CONGESTED_ROAD] : palet[CONGESTED_ROAD] /*end_arrow: 10*/;
		//		} else {
		//			draw shape color: palet[ROAD_POLLUTION_DISPLAY] /*end_arrow: 10*/;
		//		}
	}

}

//species vehicle skills: [driving] {
//	string type;
//	point target;
//	float time_to_go;
//	bool recompute_path <- false;
//	path my_path;
//
//	init {
//		speed <- 3*sizeCoeff + rnd(10) #km / #h;
////		location <- one_of(building).location;
//		location <- any(road_network.vertices);
//	}
//
//	reflex choose_new_target when: target = nil and time >= time_to_go {
//		target <-any(road_network.vertices);// road_network.vertices closest_to any(building);
//	}
//
//	reflex move when: target != nil {
//		float start <- machine_time;
//		do goto target: target on: road_network recompute_path: recompute_path;
//		if location = target {
//			target <- nil;
//			time_to_go <- time; //+ rnd(15)#mn;
//		}
//
//		if (recompute_path) {
//			recompute_path <- false;
//		}
//
//		float end <- machine_time;
//		time_vehicles_move <- time_vehicles_move + (end - start);
//	}
//
//	float pollution_from_speed {
//		float returnedValue <- 1.0;		
//		return (returnedValue);
//	}
//
//	float get_pollution {
//		return pollution_from_speed() *1;// coeff_vehicle[type];
//	}
//
//	aspect default {
//		switch type {
//			match "car" {
//				draw rectangle(10*sizeCoeff, 5*sizeCoeff) rotate: heading color: palet[CAR] depth: 5*sizeCoeff;
//			}
//
//			match "motorbike" {
//				draw rectangle(5*sizeCoeff, 2*sizeCoeff) rotate: heading color: palet[MOTOBYKE] depth: 7*sizeCoeff;
//			}
//
//		}
//
//	}
//
//}
species intersection skills: [intersection_skill] {
	rgb color;
	bool is_traffic_signal;
	float time_to_change <- 30 #s;
	float counter <- rnd(time_to_change);
	list<road> ways1;
	list<road> ways2;
	bool is_green;
	rgb color_fire;

	action initialize {
		if (is_traffic_signal) {
			do compute_crossing;
			stop << [];
			if (flip(0.5)) {
				do to_green;
			} else {
				do to_red;
			}

		}

	}

	action compute_crossing {
		if (length(roads_in) >= 2) {
			road rd0 <- road(roads_in[0]);
			list<point> pts <- rd0.shape.points;
			float ref_angle <- last(pts) direction_to rd0.location;
			loop rd over: roads_in {
				list<point> pts2 <- road(rd).shape.points;
				float angle_dest <- last(pts2) direction_to rd.location;
				float ang <- abs(angle_dest - ref_angle);
				if (ang > 45 and ang < 135) or (ang > 225 and ang < 315) {
					ways2 << road(rd);
				}

			}

		}

		loop rd over: roads_in {
			if not (rd in ways2) {
				ways1 << road(rd);
			}

		}

	}

	action to_green {
		stop[0] <- ways2;
		color_fire <- #yellow;
		is_green <- true;
	}

	action to_red {
		stop[0] <- ways1;
		color_fire <- #red;
		is_green <- false;
	}

	reflex dynamic_node when: is_traffic_signal {
		counter <- counter + step;
		if (counter >= time_to_change) {
			counter <- 0.0;
			if is_green {
				do to_red;
			} else {
				do to_green;
			}

		}

	}

	aspect base {
		if (is_traffic_signal) {
			draw circle(8) depth: 5 color: color_fire;
		} else {
		//			draw circle(2) depth:15  color: color;
		}

	}

}

species base_vehicle skills: [driving] {
	rgb color <- rnd_color(255);
	graph road_graph;
	string type; 
	point compute_position {
	// Shifts the position of the vehicle perpendicularly to the road,
	// in order to visualize different lanes
		if (current_road != nil) {
			float dist <- (road(current_road).num_lanes - current_lane - mean(range(num_lanes_occupied - 1)) - 0.5) * lane_width * sizeCoeff;
			if violating_oneway {
				dist <- -dist;
			}

			point shift_pt <- {cos(heading + 90) * dist, sin(heading + 90) * dist};
			return location + shift_pt;
		} else {
			return {0, 0};
		}

	} 
	
	aspect base {
		if (current_road != nil) {
			point pos <- compute_position();
			draw rectangle(vehicle_length * sizeCoeff, lane_width * num_lanes_occupied * sizeCoeff) at: pos color: color rotate: heading depth: 1 * sizeCoeff border: #black;
			//			draw triangle(lane_width * num_lanes_occupied*10) 
			//				at: pos color: #white rotate: heading + 90 border: #black;
		}

	}

}

species vehicle_random parent: base_vehicle {
	float aqh <- 0.0;
	bool recompute_path <- false;

	init {
		road_graph <- road_network;
		location <- one_of(non_deadend_nodes).location;
		right_side_driving <- true;
	}

	float pollution_from_speed {
		float returnedValue <- 1.0;		
		return (returnedValue);
	}

	float get_pollution {
		return pollution_from_speed() *1;// coeff_vehicle[type];
	}

	// Move the vehicle to a random node when it reaches a deadend
	reflex relocate when: next_road = nil and distance_to_current_target = 0.0 {
		do unregister;
		location <- one_of(non_deadend_nodes).location;
	}

	reflex commute {
		do drive_random graph: road_graph;
	}

}

species motorbike_random parent: vehicle_random {
	float aqh <- 15 + rnd(50.0);

	init {
		vehicle_length <- 3.9 #m;
		num_lanes_occupied <- 1;
		max_speed <- (10 + rnd(20)) #km / #h;
		proba_block_node <- 0.0;
		proba_respect_priorities <- 1.0;
		proba_respect_stops <- [1.0];
		proba_use_linked_road <- 0.5;
		lane_change_limit <- 2;
		linked_lane_limit <- 1;
	}

}

species car_random parent: vehicle_random {
	float aqh <- 20 + rnd(100.0);

	init {
		vehicle_length <- 6.8 #m;
		num_lanes_occupied <- 2;
		max_speed <- (20 + rnd(10)) #km / #h;
		proba_block_node <- 0.0;
		proba_respect_priorities <- 1.0;
		proba_respect_stops <- [1.0];
		proba_use_linked_road <- 0.0;
		lane_change_limit <- 2;
		linked_lane_limit <- 0;
	}

}

species taxi_random parent: vehicle_random {
	float aqh <- 5 + rnd(2.0);
	rgb color <- brewer_colors("Greens")[int(13 - energy)];
	float energy <- 1+rnd(11.0);

	init {
		vehicle_length <- 6.8 #m;
		num_lanes_occupied <- 2;
		max_speed <- (10 + rnd(10)) #km / #h;
		proba_block_node <- 0.0;
		proba_respect_priorities <- 1.0;
		proba_respect_stops <- [1.0];
		proba_use_linked_road <- 0.0;
		lane_change_limit <- 2;
		linked_lane_limit <- 0;
	}

	reflex ss {
		energy <- energy > 2 ? energy - 0.1 : 12;
		color <- brewer_colors("Greens")[int(13 - energy)];
	}

}

species building schedules: [] {
	float height;
	string type;
	float aqi;
	rgb color;
	file texture;
	float depth;
	agent p_cell;

	init {
		if height < min_height {
			height <- mean_height + rnd(0.3, 0.3);
		}

	}

	aspect border {
		draw shape border: #blue wireframe: true color: #blue;
	}

	aspect default {
	//		if (display_mode = 0) {
	//			draw shape texture: [roof_texture.path, texture.path] depth: depth color: (type = type_outArea) ? palet[BUILDING_OUTAREA] : palet[BUILDING_BASE] /*border: #darkgrey*/
	//			/*depth: height * 10*/;
	//		} else {
		draw shape texture: [roof_texture.path, texture.path] color: (type = type_outArea) ? palet[BUILDING_OUTAREA] : world.get_pollution_color(aqi) /*border: #darkgrey*/ depth: depth;
		//		}

	}

}

//species decoration_building schedules: [] {
//	float height;
//
//	aspect default {
//		draw shape color: palet[DECO_BUILDING] border: #darkgrey depth: height * 10;
//	}
//
//}

//species natural schedules: [] {
//
//	aspect default {
//		draw shape color: palet[NATURAL]; //border: #darkblue;
//	}
//
//}

//species dummy_road schedules: [] {
//	int mid;
//	int oneway;
//	int linkToRoad;
//	float density <- 5.0;
//	road linked_road;
//	int segments_number;
//	int aspect_size <- 5;
//	list<float> segments_x <- [];
//	list<float> segments_y <- [];
//	list<float> segments_length <- [];
//	list<point> lane_position_shift <- [];
//	int movement_time <- 5;
//
//	init {
//	// Remove duplicate points
//		int i <- 0;
//		list<point> filtered_points <- shape.points;
//		loop while: i < length(filtered_points) - 1 {
//			if filtered_points[i] = filtered_points[i + 1] {
//				remove from: filtered_points index: i;
//			} else {
//				i <- i + 1;
//			}
//
//		}
//
//		shape <- polyline(filtered_points);
//		segments_number <- length(shape.points) - 1;
//		loop j from: 0 to: segments_number - 1 {
//			if shape.points[j + 1] != shape.points[j] {
//				add shape.points[j + 1].x - shape.points[j].x to: segments_x;
//				add shape.points[j + 1].y - shape.points[j].y to: segments_y;
//			}
//
//		}
//
//	}
//
//	aspect default {
//		point new_point;
//		int lights_number <- int(shape.perimeter / 50);
//		draw shape color: palet[DUMMY_ROAD] /*end_arrow: 10*/;
//
//		//		loop i from: 0 to: segments_number-1 { 
//		//			// Calculate rotation angle
//		//			point u <- {segments_x[i] , segments_y[i]};
//		//			point v <- {1, 0};
//		//			float dot_prod <- u.x * v.x + u.y * v.y;
//		//			float angle <- acos(dot_prod / (sqrt(u.x ^ 2 + u.y ^ 2) + sqrt(v.x ^ 2 + v.y ^ 2)));
//		//			angle <- (u.x * -v.y + u.y * v.x > 0) ? angle : 360 - angle;
//		//			
//		//		 	loop j from:0 to: lights_number-1 {
//		// 				new_point <- {shape.points[i].x + segments_x[i] * (j + mod(cycle, movement_time)/movement_time)/lights_number, 
//		// 											shape.points[i].y + segments_y[i] * (j + mod(cycle, movement_time)/movement_time)/lights_number};
//		//				draw rectangle(10, 4) at: new_point color: #yellow rotate: angle depth: 3;
//		//			}
//		//		}	
//	}
//
//}
