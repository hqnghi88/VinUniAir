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
		}

		create vector;
		create people number:10{level<-0;}
		create people number:10{level<-1;}
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


species people skills: [moving]{
	rgb color <- rnd_color(255);
	float speed <- gauss(5,1.5) #km/#h min: 2 #km/#h;
 	int level<-0;
 	reflex mv{
 		do wander speed:1#m/#s amplitude:90.0;
 	}
	aspect default {
		  
			draw obj_file("people.obj", 90::{-1,0,0}) size:4
			at: location + {0,0,5.5+level*20} rotate: heading - 90 color: color;
		 
	}
}

species vector {
	file my_csv_file;
	list<matrix<float>> datas <- [[], [], [], [], [], [], [], [], [], [], []];
	int idx <- 1;

	init {
		do readdata;
	}

	action readdata {
		loop i from: 0 to: 10 {
//					my_csv_file <- csv_file("a" + i + ".csv", ",", false);
			my_csv_file <- csv_file("a_._" + idx + ".csv", ",", false);
			datas[i] <- matrix<float>(my_csv_file);
		}

	}

	reflex s when: cycle mod 10 = 0{
		idx <- (idx > 9) ? 1 : (idx + 1);
		do readdata;
	}

	aspect default {
		if (length(datas) > 0) {
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
				draw line([{p1.x, HH-p1.y, p1.z}, {p3.x, HH-p3.y, p3.z}]) color: #red;
				//				draw circle(0.1) at_location p1 color:#red;
				//			}

			}
			//		write minx;
			//		write miny;
		}

	}

}

species object skills: [pedestrian]{
//	geometry shape <- obj_file("a.obj") as geometry;
	aspect default {
		draw obj_file("a.obj") size:111 at: location color: color;
	}

}

experiment Display type: gui {
	output {
		display complex background: #white type: 3d {
			species vector;
			species people;
			species object transparency: 0.9 ;//position: {WW / 2, HH / 2, 0.18};
		}

	}

}
