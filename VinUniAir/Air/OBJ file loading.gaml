/**
* Name: Complex Object Loading
* Author:  Arnaud Grignard
* Description: Provides a  complex geometry to agents (svg,obj or 3ds are accepted). The geometry becomes that of the agents.
* Tags:  load_file, 3d, skill, obj
*/
model obj_loading

global {

//	geometry shape <- square(100);
	obj_file ooo <- obj_file("a.obj");
	geometry shape <- envelope(ooo);
	//	float minx <- 11111;
	//	float miny <- 11111;
	float WW;
	float HH;

	init {
		WW <- world.shape.width;
		HH <- world.shape.height;
		//			do filter;
		create object {
			location <- world.location + {0, 0, 20};
			//			shape <- world.shape;
		}

		create base3d {
			ss <- envelope(world.shape);
		}
		//		save object to: "buildings.shp" format: "shp";
		create vector;
		//		create people number:10{level<-0;}
		//		create people number:10{level<-1;}
	}

	action filter {
		file my_csv_file;
		matrix<float> data;
		loop idx from: 0 to: 10 {
			my_csv_file <- csv_file("a" + idx + ".csv", ",", false);
			data <- matrix<float>(my_csv_file);
			matrix<float> data1 <- [];
			loop i from: 1 to: data.rows - 1 {
				point p2 <- {data[1, i], data[2, i], data[3, i]};
				if (i mod 4 = 0) {
					data1 <- ((data row_at i) as matrix) append_vertically data1;
				}

			}
			//			save ["p","U:0","U:1","U:2","Points:0","Points:1","Points:2"] to:"a_._" + idx + ".csv" format: "csv" rewrite: true;

			//			write data1;
			save data1 to: "a_._" + idx + ".csv" format: "csv" rewrite: true header: false;
		}

	}

}

species people skills: [moving] {
	rgb color <- rnd_color(255);
	float speed <- gauss(5, 1.5) #km / #h min: 2 #km / #h;
	int level <- 0;

	reflex mv {
		do wander speed: 1 #m / #s amplitude: 90.0;
	}

	aspect default {
		draw obj_file("people.obj", 90::{-1, 0, 0}) size: 4 at: location + {0, 0, 5.5 + level * 20} rotate: heading - 90 color: color;
	}

}

species vector {
	file my_csv_file;
	list<matrix<float>> datas <- [[], [], [], [], [], [], [], [], [], [], []];
	list<list<geometry>> geos <- [[], [], [], [], [], [], [], [], [], [], []];
	int idx <- -1;

	init {
	//		do readdata;
	}

	action readdata {
		loop i from: 0 to: 10 {
			my_csv_file <- csv_file("a" + i + ".csv", ",", false);
			//			my_csv_file <- csv_file("a_._" + idx + ".csv", ",", false);
			datas[i] <- matrix<float>(my_csv_file);
		}

	}

	reflex s {
		idx <- (idx > 9) ? 0 : (idx + 1);
		if (geos[idx] = []) {
		//			my_csv_file <- csv_file("a" + idx + ".csv", ",", false);
			my_csv_file <- csv_file("a_._" + idx + ".csv", ",", false);
			datas[idx] <- matrix<float>(my_csv_file);
		}

	}

	aspect default {
		if (geos[idx] != []) {
			loop p over: geos[idx] {
				draw p as geometry color: #red end_arrow: 0.5;
			}

		} else if (length(datas) > 0) {
		//			write geos[idx] ;
			geos[idx] <- [];
			matrix<float> data <- datas[idx];
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
				geometry ll <- line([{p1.x, HH - p1.y, p1.z}, {p3.x, HH - p3.y, p3.z}]);
				draw ll color: #red width: 1 end_arrow: 0.5;
				geos[idx] <+ (ll);
				//				draw circle(0.1) at_location p1 color:#red;
				//			}

			}
			//		write minx;
			//		write miny;
		}

	}

}

species base3d {
	geometry ss;

	aspect default {
	//		draw ss color: #red;
		float ww <- ss.width;
		float hh <- ss.height;
		draw (box({1, hh, 41}) at_location {0.5, hh / 2, 0}) color: #red;
		draw (box({1, hh, 41}) at_location {ww - 0.5, hh / 2, 0}) color: #red;
		draw (box({ww, 1, 41}) at_location {ww / 2, 0.5, 0}) color: #red;
		draw (box({ww, 1, 41}) at_location {ww / 2, hh - 0.5, 0}) color: #red;
		//		
		//				 
		draw (box({1, 17, 41}) at_location {26.5, 8.5, 0}) color: #red;
		draw (box({1, 1, 41}) at_location {26.5, 26.5, 0}) color: #red;
		draw (box({1, hh - 27, 41}) at_location {36.5, 27 + (hh - 27) / 2, 0}) color: #red;
		draw (box({1, 17, 41}) at_location {71.5, 8.5, 0}) color: #red;
		draw (box({1, hh - 26, 41}) at_location {71.5, 26 + (hh - 26) / 2, 0}) color: #red;
		draw (box({28, 1, 41}) at_location {14, 27.5, 0}) color: #red;
		draw (box({28, 1, 41}) at_location {49, 27.5, 0}) color: #red;
		draw (box({2, 1, 41}) at_location {71, 27.5, 0}) color: #red;

		//stairs
		draw (box({9, 24, 2}) at_location {31, 12, 0}) color: #red;
		draw (box({9, 20, 2}) at_location {31, 10, 2}) color: #red;
		draw (box({9, 16, 2}) at_location {31, 8, 4}) color: #red;
		draw (box({9, 12, 2}) at_location {31, 6, 6}) color: #red;
		draw (box({9, 8, 2}) at_location {31, 4, 8}) color: #red;
		draw (box({36, 8, 10}) at_location {53.5, 4, 0}) color: #red;
		draw (box({33, 8, 2}) at_location {55, 4, 10}) color: #red;
		draw (box({27, 8, 2}) at_location {58, 4, 12}) color: #red;
		draw (box({21, 8, 2}) at_location {61, 4, 14}) color: #red;
		draw (box({15, 8, 2}) at_location {64, 4, 16}) color: #red;
		draw (box({9, 8, 2}) at_location {67, 4, 18}) color: #red;

		//end-stairs
		
		//floor1
		draw (box({26, 28, 1}) at_location {13, 14, 20}) color: #red;
		draw (box({10, 12, 1}) at_location {31, 22, 20}) color: #red;
		draw (box({36, 20, 1}) at_location {54, 18, 20}) color: #red;
		draw (box({40, 28, 1}) at_location {91, 14, 20}) color: #red;
		draw (box({ww, hh - 28, 1}) at_location {ww / 2, 28 + (hh - 28) / 2, 20}) color: #red;
		//end floor1
		
		
		//ceiling 
		
		draw (box({ww, 44, 1}) at_location {ww / 2, 22, 41}) color: #red;
		draw (box({84, 12, 1}) at_location {42, 50, 41}) color: #red;
		draw (box({15, 12, 1}) at_location {ww-7.5, 50, 41}) color: #red;
		draw (box({ww, 10, 1}) at_location {ww / 2, hh - 5, 41}) color: #red;
		
		//end ceiling
		
		
	}

}

species object {

	aspect default {
		draw obj_file("a.obj") size: 111 at: location color: color;
	}

}

experiment Display type: gui {
	output {
		display complex background: #white type: 3d {
			camera 'default' location: #from_above;
			species vector;
			//			species people;
			species base3d transparency: 0.9; //position: {WW / 2, HH / 2, 0.18};
			species object transparency: 0.9; //position: {WW / 2, HH / 2, 0.18};
		}
		//		display complex1 background: #white type: 3d { 
		//			camera 'default' location:#from_up_left;
		//			species vector;
		//			//			species people;
		//			species object transparency: 0.9; //position: {WW / 2, HH / 2, 0.18};
		//		}
		//		display complex2 background: #white type: 3d { 
		//			camera 'default' location:#from_up_right;
		//			species vector;
		//			//			species people;
		//			species object transparency: 0.9; //position: {WW / 2, HH / 2, 0.18};
		//		}
		//
		//		display complex3 background: #white type: 3d { 
		//			camera 'default' location:#from_above;
		//			species vector;
		//			//			species people;
		//			species object transparency: 0.9; //position: {WW / 2, HH / 2, 0.18};
		//		}

	}

}
