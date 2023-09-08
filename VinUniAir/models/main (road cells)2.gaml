/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main 

global {
	string appkey<-"uoJREhBjzEvVR9MYz3QXiAyYfmGWxOkG";
	image_file static_map_request;
	string map_center <- "48.8566140,2.3522219"; 
	int map_zoom <- 16 max: 20 min: 0;
	point map_size <-{1567,1107};
//	point map_size <-{200,200};
	
	
	action load_map
	{ 
		float s<-world.shape.height/world.shape.width;
		map_size<-{500,500*s}; 
		string request<-"https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/"
		+"["+map_center+"]/"+int(map_size.x)+"x"+int(map_size.y)+"@2x?"
		+"access_token=pk.eyJ1IjoiaHFuZ2hpODgiLCJhIjoiY2t0N2w0cGZ6MHRjNTJ2bnJtYm5vcDB0YyJ9.oTjisOggN28UFY8q1hiAug";
		write "Request : " + request;
		static_map_request <- image_file(request,"JPEG"); 
	}
 
	string resources_dir <- "../includes/bigger_map/";	
	shape_file roads_shape_file <- shape_file(resources_dir + "roads.shp");
	
	shape_file buildings_shape_file <- shape_file(resources_dir + "buildings.shp");

	geometry shape <- envelope(buildings_shape_file);
	//	list<pollutant_grid> active_cells;
	init {
		
//		map answers <- user_input_dialog("Center of the map can be a pair lat,lon (e.g; '48.8566140,2.3522219')", [enter("Center",map_center),enter("Zoom x",map_zoom),enter("Size", map_size)]);
//	    map_center <- answers["Center"]; 
//		map_zoom <- int(answers["Zoom x"]);
//		map_size <- point(answers["Size"]);
//		point loc<-(world.shape.location CRS_transform("EPSG:4326")).location;
//		map_center <-""+loc.y+","+loc.x ;
//		&boundingBox=38.915,-77.072,38.876,-77.001&size=1100,500@2x
//		point l1<-{2393241.4566,11792211.7398};
//		point l2<-{2389492.9242,11796892.4212};
//		l1<-(l1 CRS_transform("EPSG:4326")).location;
//		l2<-(l2 CRS_transform("EPSG:4326")).location;
//		map_center <-""+l1.y+","+l1.x+","+l2.y+","+l2.x;
		geometry loc<-(world.shape CRS_transform("EPSG:4326"));
		map_center <-""+loc.points[0].y+","+loc.points[0].x+","+loc.points[2].y+","+loc.points[2].x;
		write loc;
		map_center<-"105.93916169971295,20.98776569973214,105.94918339971682,20.99437559973104";
		write map_center;
		do load_map;
		

		create road from: roads_shape_file {}
		create building from: buildings_shape_file { 
		} 

	}
 
}
species building{}
species road{}

experiment exp { 
	output {

		display main type: 3d { 
 
			image static_map_request;
			
			species building; 	
		}

	}

}