/***
* Name: mainroadcells
* Author: minhduc0711
* Description: 
* Tags: Tag1, Tag2, TagN
***/
model main
 

global {
	shape_file building_shp <- shape_file("../includes/buildingVin1.shp");
	geometry shape<-envelope(building_shp);
	init{
		create building from:building_shp with:[level::int(read("LVL"))]{
			height<-level*5+rnd(5)*5+3;
		}
	}
}
species building{
	int level<-0;
	int height<-0;
	aspect default{
		draw shape depth:height;
		
	}
}
experiment exp4p {
	output synchronized: true {
		display main type: opengl background: #black axes: false {
			image ("../includes/vin.png");
			species building;
		}

	}

}