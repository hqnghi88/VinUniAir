/**
* Name: Perfect Gas
* Author: Arnaud Grignard - Alexis Drogoul 2021
* Description: This is a model that shows how the physics engine works with and without gravity. Particles, provided with an initial impulse,
* collide each other and the walls. Without gravity and friction, and with a perfect restitution, this movement can go on forever.
* The user can apply gravity or not, as well as remove one (or several) of the walls to alter this behavior.
* Tags: physics_engine, skill, 3d, spatial_computation
*/
model Gas

/**
 * The model is inheriting from 'physical_world' a special model species that provides access to the physics engine -- and the possibility
 * to manage physical agents. In this model, the world itself is not a physical agent
 */
global parent: physical_world {
	bool use_native <- true;
	point gravity <- {0.0, 0.0, 0.0};
	bool withGravity <- false parameter: "Enable gravity" on_change: {
		gravity <- withGravity ? {0.0, 0.0, -9.81} : {0.0, 0.0, 0.0};
	};
	bool accurate_collision_detection <- true;
	bool show_walls <- true parameter: "Show walls";
	//	shape_file wall_shape_file <- shape_file("walls.shp");
	//	//	geometry shape <- rectangle(width, width);
	//	geometry shape <- envelope(wall_shape_file);
	obj_file ooo <- obj_file("a.obj");
	geometry shape <- envelope(ooo);
	int wwidth;
	int hheight <- 20;
	float step <- 0.01;

	init {
		float ww <- shape.width;
		float hh <- shape.height;
		WW <- world.shape.width;
		HH <- world.shape.height;
		list<geometry> MM <- [];
		MM <+ (box({ww, hh, 1}) at_location {ww / 2, hh / 2, 0});
		MM <+ (box({1, hh, 41}) at_location {0.5, hh / 2, 0});
		MM <+ (box({1, hh, 41}) at_location {ww - 0.5, hh / 2, 0});
		MM <+ (box({ww, 1, 41}) at_location {ww / 2, 0.5, 0});
		MM <+ (box({ww, 1, 41}) at_location {ww / 2, hh - 0.5, 0});
		//		
		//				 
		MM <+ (box({1, 17, 41}) at_location {26.5, 8.5, 0});
		MM <+ (box({1, 1, 41}) at_location {26.5, 26.5, 0});
		MM <+ (box({1, hh - 27, 41}) at_location {36.5, 27 + (hh - 27) / 2, 0});
		MM <+ (box({1, 17, 41}) at_location {71.5, 8.5, 0});
		MM <+ (box({1, hh - 26, 41}) at_location {71.5, 26 + (hh - 26) / 2, 0});
		MM <+ (box({28, 1, 41}) at_location {14, 27.5, 0});
		MM <+ (box({28, 1, 41}) at_location {49, 27.5, 0});
		MM <+ (box({2, 1, 41}) at_location {71, 27.5, 0});

		//stairs
		MM <+ (box({9, 24, 2}) at_location {31, 12, 0});
		MM <+ (box({9, 20, 2}) at_location {31, 10, 2});
		MM <+ (box({9, 16, 2}) at_location {31, 8, 4});
		MM <+ (box({9, 12, 2}) at_location {31, 6, 6});
		MM <+ (box({9, 8, 2}) at_location {31, 4, 8});
		MM <+ (box({36, 8, 10}) at_location {53.5, 4, 0});
		MM <+ (box({33, 8, 2}) at_location {55, 4, 10});
		MM <+ (box({27, 8, 2}) at_location {58, 4, 12});
		MM <+ (box({21, 8, 2}) at_location {61, 4, 14});
		MM <+ (box({15, 8, 2}) at_location {64, 4, 16});
		MM <+ (box({9, 8, 2}) at_location {67, 4, 18});

		//end-stairs

		//floor1
		MM <+ (box({26, 28, 1}) at_location {13, 14, 20});
		MM <+ (box({10, 12, 1}) at_location {31, 22, 20});
		MM <+ (box({36, 20, 1}) at_location {54, 18, 20});
		MM <+ (box({40, 28, 1}) at_location {91, 14, 20});
		MM <+ (box({ww, hh - 28, 1}) at_location {ww / 2, 28 + (hh - 28) / 2, 20});
		//end floor1


		//ceiling 
		MM <+ (box({ww, 44, 1}) at_location {ww / 2, 22, 41});
		MM <+ (box({84, 12, 1}) at_location {42, 50, 41});
		MM <+ (box({15, 12, 1}) at_location {ww - 7.5, 50, 41});
		MM <+ (box({ww, 10, 1}) at_location {ww / 2, hh - 5, 41});
		create wall from: MM;
		wwidth <- int(world.shape.width);
		//10000 particles are created, randomly located in a virtual box in the center of the world
		//		create particles number: 10000 {
		//			location <- {rnd(wwidth / 8) + wwidth / 6, rnd(hh / 8) + hh / 2, rnd(hheight / 4) + hheight / 4};
		//		}

		//		create wall from: wall_shape_file {
		//			shape <- box(shape.width, shape.height, hheight) at_location location;
		//		}
		////		save wall  to:"walls.shp" format:"shp" ;
		//		//We create walls, large boxes that prevent the particles from moving outside
		//		//		create wall from: [box(width, 3*width, width) at_location {-width/2, width/2, 0},box(width, 3*width, width) at_location {3*width/2, width/2, 0},box(width, width, width) at_location {width/2, -width/2, 0},box(width, width, width) at_location {width/2, 3*width/2,  0}];
		//		create wall from: [box({53 * wwidth, 53 * wwidth, 1}) at_location {wwidth / 2, wwidth / 2, hheight-1}, 
		//			box({53 * wwidth, 53 * wwidth, 1}) at_location {wwidth / 2, wwidth / 2, -1}] {
		//			ceiling <- true;
		//		}
		my_csv_file <- csv_file("a_._0.csv", ",", false);
		datas[0] <- matrix<float>(my_csv_file);
		//			my_csv_file <- csv_file("a" + idx + ".csv", ",", false);
		my_csv_file <- csv_file("a_._0.csv", ",", false);
		datas[0] <- matrix<float>(my_csv_file);
	}

	file my_csv_file;
	list<matrix<float>> datas <- [[], [], [], [], [], [], [], [], [], [], []];
	float WW;
	float HH;

	reflex s when: every(100 #cycle) {
		matrix<float> data <- datas[0];
		loop i from: 1 to: data.rows - 1 {
		//loop on the matrix columns 
			float p <- data[0, i];
			point p2 <- {data[1, i], data[2, i], data[3, i]};
			//			if (p2.x + p2.y + p2.z > 0) {
			//10.5
			//11.119
			point p1 <- {data[4, i] - 10.5, data[5, i] - 11.119, data[6, i]};
			//				if(p1.x<minx){minx<-p1.x;}
			//				if(p1.y<miny){miny<-p1.y;}
			point p3 <- p1 + p2;
			create particles {
				location <- p3;
				velocity <- {p1.x, HH - p1.y, p1.z} - {p3.x, HH - p3.y, p3.z};
			}
			//			geometry ll <- line([{p1.x, HH - p1.y, p1.z}, {p3.x, HH - p3.y, p3.z}]); 

		}

	}

}

/**
 * The walls are static physical bodies that offer no friction or restitution whatsoever.
 */
species wall skills: [static_body] {
	bool ceiling <- false;
	float friction <- 0.0;
	float restitution <- 1.0;

	aspect default {
		if (show_walls) {
			draw shape color: #darkgray wireframe: ceiling ? true : false;
		}

	}

}

/**
 * Particles are dynamic bodies that wander around. They provide a perfect restitution (i.e. bounciness) and no friction.
 */
species particles skills: [dynamic_body] {
	geometry shape <- sphere(0.2);
	rgb color <- one_of(brewer_colors("Reds"));
	float friction <- 0.0;
	// No damping, which woud slow down their move
	float damping <- 0.0;
	float angular_damping <- 0.0;
	// Perfect restitution ('bouncing')
	float restitution <- 0.9;
	// An initial velocity is provided to the agents
	//	init {
	//		float amp <- 100.0;
	//		velocity <- {rnd(amp) - amp / 2, rnd(amp) - amp / 2, rnd(amp) - amp / 2};
	//	}
	reflex manage_location when: (location.z < -2) or (location.z > 45) {
		do die;
	}
	// A (commented out) callback action can be defined, for instance to exchange the colors of the particles when they collide
	action contact_added_with (agent other) {
		if (other is particles) {
			color <- particles(other).color;
		}

	}

}

experiment "Chamber" type: gui {
// Allows to play with the step of the simulation (and physics step)
	parameter "Physics resolution step (in sec)" var: step min: 0.001 max: 0.1;
	// With this command, the user can destroy one of the walls at random
	user_command "Open one wall" color: #red {
		ask (one_of(wall)) {
			do die;
		}

	}

	output {
		display Cube type: 3d background: #white axes: false {
			species particles {
				draw shape color: color;
			}

			species wall transparency: 0.6;
		}

	}

}

