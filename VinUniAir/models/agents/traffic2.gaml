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
	//Map containing all the weights for the road network graph
	map<road, float> road_weights;
}

species road schedules: [] {
	rgb color <- #white;
	string type;
	bool oneway;
	bool s1_closed;
	bool s2_closed;
	bool closed;
	float capacity <- 1 + shape.perimeter / 30;
	float speed_coeff <- 12.0; // 3.0 + rnd(6.0) min: 0.1;
	action update_speed_coeff (int n_cars_on_road, int n_motorbikes_on_road) {
		speed_coeff <- (n_cars_on_road + n_motorbikes_on_road <= capacity) ? 1 : exp(-(n_motorbikes_on_road + 4 * n_cars_on_road) / capacity);
	}

	aspect default {
	//		if (display_mode = 0) {
	//			if (closed) {
	//				draw shape + 50 color: palet[CLOSED_ROAD_TRAFFIC];
	//			} else {
		draw shape + (speed_coeff) color: brewer_colors("Reds")[int(13 - speed_coeff)] /*end_arrow: 10*/;
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

species AQI {
	geometry shape <- circle(30);
	string description;
	float aqi;

	reflex pollute {
		instant_heatmap[location] <- instant_heatmap[location] +  aqi / 10;
	}

	aspect default {
		draw "" + aqi color: #violet + 10 at: location font: font("SansSerif", 32, #bold);
		//		draw square(500) color: #cyan;
	}

}

species traffic_incident {
	geometry shape <- circle(30);
	string description;

	reflex flow when: flip(0.5) {
	//		list<road> tmp<-road at_distance 1;
		create dummy_car {
		//			target_roads <- tmp;
			targetP <- circle(10) at_location (myself.location);
			location <- any_location_in(targetP);
		}

	}

	aspect default {
	//		draw description color: #pink at: location perspective: false font: font("SansSerif", 36, #bold);
		draw triangle(500) color: #red;
	}

}

species base_vehicle skills: [moving] {
	rgb color <- rnd_color(255);
	graph road_graph;
	string type;
	bool should_die;
	//Target point of the agent
	point target;
	//Probability of leaving the building
	float leaving_proba <- 0.05;
	//Speed of the agent
	float speed <- rnd(10) #km / #h + 1;
	// Random state
	string state;
	//	list<road> target_roads;
	geometry targetP;
	bool is_electrical <- false;

	init {
		location <- any_location_in(one_of(road));
		//		if (should_die) {
		//			target_roads <- [road closest_to self];
		//		location <- any_location_in(one_of(target_roads));
		//		}

	}
	//Reflex to leave the building to another building
	reflex leave when: (target = nil) and (flip(leaving_proba)) {
		if (should_die) {
			target <- any_location_in(targetP);
		} else {
			target <- any_location_in(one_of(road));
		}

	}
	//Reflex to move to the target building moving on the road network
	reflex move when: target != nil {
	//we use the return_path facet to return the path followed
		path path_followed <- goto(target: target, on: road_network, recompute_path: false, return_path: true, move_weights: road_weights);
		if (location distance_to target < 10) {
			if (should_die) {
				do die;
			} else {
				target <- nil;
			}

		} }

	float dist <- rnd(1) * 10 + 10.0 * rnd(3);
	point compute_position {
	// Shifts the position of the vehicle perpendicularly to the road,
	// in order to visualize different lanes
		point shift_pt <- {cos(heading + 90) * dist, sin(heading + 90) * dist};
		return location + shift_pt;
	}

	aspect base {
	//				draw circle(10);
		point pos <- compute_position();
		draw circle(20) at: pos rotate: heading depth: 1 * sizeCoeff;
		//		draw rectangle(1 * sizeCoeff, sizeCoeff) color: color rotate: heading depth: 1 * sizeCoeff border: #black;
	} }

species vehicle_random parent: base_vehicle {
	float aqh <- 0.0;
	bool recompute_path <- false;

	init {
		road_graph <- road_network;
		location <- any_location_in(any(road)); //one_of(non_deadend_nodes).location;
	}

	float pollution_from_speed {
		float returnedValue <- 1.0;
		return (returnedValue);
	}

	float get_pollution {
		return pollution_from_speed() * 1; // coeff_vehicle[type];
	}
	// 
	//	reflex commute {
	//		do drive_random graph: road_graph;
	//	}

}

species motorbike_random parent: vehicle_random {
	float aqh <- 15 + rnd(50.0);

	init {
	//		vehicle_length <- 3.9 #m;
	//		num_lanes_occupied <- 1;
		speed <- (10 + rnd(20)) #km / #h;
		//		proba_block_node <- 0.0;
		//		proba_respect_priorities <- 1.0;
		//		proba_respect_stops <- [1.0];
		//		proba_use_linked_road <- 0.5;
		//		lane_change_limit <- 2;
		//		linked_lane_limit <- 1;
	}

}

species car_random parent: vehicle_random {
	float aqh <- 20 + rnd(100.0);

	init {
	//		vehicle_length <- 6.8 #m;
	//		num_lanes_occupied <- 2;
		speed <- (20 + rnd(10)) #km / #h;
		//		proba_block_node <- 0.0;
		//		proba_respect_priorities <- 1.0;
		//		proba_respect_stops <- [1.0];
		//		proba_use_linked_road <- 0.0;
		//		lane_change_limit <- 2;
		//		linked_lane_limit <- 0;
	}

}

species dummy_car parent: vehicle_random {
	float aqh <- 20 + rnd(100.0);

	init {
		should_die <- true;
		//		vehicle_length <- 6.8 #m;
		//		num_lanes_occupied <- 2;
		speed <- (20 + rnd(10)) #km / #h;
		//		proba_block_node <- 0.0;
		//		proba_respect_priorities <- 1.0;
		//		proba_respect_stops <- [1.0];
		//		proba_use_linked_road <- 0.0;
		//		lane_change_limit <- 2;
		//		linked_lane_limit <- 0;
	}

}

species bus_random parent: vehicle_random {
	float aqh <- 5 + rnd(2.0);
	rgb color <- brewer_colors("Greens")[int(13 - energy)];
	float energy <- 1 + rnd(11.0);

	init {
	//		vehicle_length <- 6.8 #m;
	//		num_lanes_occupied <- 2;
		speed <- (10 + rnd(10)) #km / #h;
		//		proba_block_node <- 0.0;
		//		proba_respect_priorities <- 1.0;
		//		proba_respect_stops <- [1.0];
		//		proba_use_linked_road <- 0.0;
		//		lane_change_limit <- 2;
		//		linked_lane_limit <- 0;
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
		draw shape.contour+10 border: #gray color: #pink;
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
