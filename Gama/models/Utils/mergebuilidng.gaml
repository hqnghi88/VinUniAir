
model mergebuilding


global { 
	shape_file DH_building0_shape_file <- shape_file("../../includes/DH_building.shp");
	geometry shape<-envelope(DH_building0_shape_file);
	init{
		create building from:DH_building0_shape_file;
		ask building{
			geometry s<-self.shape;
			ask (building-self) at_distance 1{
				s<-convex_hull(s+self.shape);
				do die;
			}
			self.shape<-s;
		}
		ask building where (each.shape.area<200){
			do die;
		}
//		save building to:"../../includes/DH_buildings.shp" format:"shp";
	}
}
 
species building {
	string type;
	aspect default{ 
		draw shape color: #gray ;
	}
}
  
experiment vr_xp  type:gui { 

		 
	output { 
		//In addition to the layers in the map display, display the unity_player and let the possibility to the user to move players by clicking on it.
		display displayVR type:3d axes:false { 
			species building;
		}
		
	} 
}