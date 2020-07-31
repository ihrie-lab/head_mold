/*************************************************
 
 Original Author

 Parametric two-part mold generator
 Author: Jason Webb
 Website: http://jason-webb.info

 Modified by

Yifu Luo 
Yuhao Chen

*************************************************/
// Model parameters
//model_filename = "6953_meshfix.stl";
//model_rotate = [90,140,40];
//model_filename = "6945_meshfix.stl";
//model_rotate = [90,0,40];
//model_filename = "2.stl";
//model_rotate = [90,180,50];
model_filename = "6950_meshfix_2.STL";
model_rotate = [0,90,-45];

model_translate = [0,2,4.5];
model_scale = 1;

//Square taken out of mold
//Rotate squares to form triangles at the bottom of the nose
squareSize=10;
squareTopRotate=[0, 0, -40];
squareBotRotate=[0,0, -40];
squareTopTranslate=[-5, 10.3, 4];
squareBotTranslate=[-5, 10.3, 4];


// Mold parameters
mold_width = 34;			// Measured along X axis
mold_height = 20;			// Measured along Y axis
mold_depth = 7;			// Measured along Z axis
mold_spacing = 3;			// Space between mold halves
rounded_corners = true;		// Rounded the corners to lessen warping
edge_radius = 0.1;			// Radius of rounded corners

// Key parameters (registration marks)
key_size = 0;		// Radius of spherical keys
key_fettle = 0.4;		// Size difference between keys and corresponding holes
key_margin = 7;	// Distance from outside edge of mold

// Pour hole parameters
pour_hole = 0; //0 for false 1 for true.
location = 0; //0 for now


side_by_side();

/****************************************
 Rotate and place both halves side by side 
 along the X axis for easy single-plate printing
*****************************************/
module side_by_side() {
	// Scoot the left half over a bit
	translate([mold_width/2 + mold_spacing/2, 0, mold_depth/2])
		bottom_half();
		
	// Rotate the top half, then scoot it over a bit
	translate([-mold_width/2 - mold_spacing/2, 0, mold_depth*3/2])
		rotate([0, 180, 0])
			top_half();	
}

/*******************************************
 Bottom half of the mold
********************************************/
module bottom_half() {
	// Create the mold form with negative keys
	difference() {

		// Create the basic mold form by subtracting the STL from a cube half it's size
        
		difference() {
			difference() {
				if(rounded_corners) 
					roundedBox([mold_width, mold_height, mold_depth], edge_radius, true);
				else
					cube(size = [mold_width, mold_height, mold_depth], center = true);
	
				scale(model_scale)
					translate(model_translate)
						rotate(model_rotate)
							import(model_filename);
                
			}
			if (pour_hole) {
 				translate(model_translate)
					translate([mold_depth,0,0])
						cylinder(h = mold_depth*2, r1 = mold_depth*2, r2 = mold_depth, center = true);
			}
		}
       
    


		// Negative key 1
		translate([-mold_width/2 + key_margin, -mold_height/2 + key_margin, mold_depth/2])
			cube(size =[key_size+key_fettle,key_size+key_fettle,key_size+key_fettle], center=true);

		// Negative key 2
		translate(squareTopTranslate)
            rotate(squareTopRotate)
			cube(squareSize, center=true);
        
	}

	// Positive key 1

	// Positive master key

}

/*******************************************
 Top half of the mold
********************************************/
module top_half() {
	// Create the mold form with negative keys
	difference() {

		// Create the mold form by subtracting the STL from a cube half it's size
		difference() {
			translate([0, 0, mold_depth])
				if(rounded_corners) 
					roundedBox([mold_width, mold_height, mold_depth], edge_radius, true);
				else
					cube(size = [mold_width, mold_height, mold_depth], center = true);

				scale(model_scale)
					translate(v = model_translate)
						rotate(model_rotate)
								import(model_filename);
		}

		// Negative master key
		translate(squareBotTranslate)
            rotate(squareBotRotate)
			cube(squareSize, center=true);
	}

	// Positive key 1
	translate(v = [mold_width/2 - key_margin, mold_height/2 - key_margin, mold_depth/2])
		sphere(key_size, $fn = 30);
		
	// Positive key 2
	translate(v = [-mold_width/2 + key_margin, -mold_height/2 + key_margin, mold_depth/2])
		//sphere(key_size, $fn = 30);
		cube(size =[key_size,key_size,key_size], center=true);
}

/******************************************
 roundedBox module from example022.scad
******************************************/
// size is a vector [w, h, d]
module roundedBox(size, radius, sidesonly)
{
	rot = [ [0,0,0], [90,0,90], [90,90,0] ];
	if (sidesonly) {
		cube(size - [2*radius,0,0], true);
		cube(size - [0,2*radius,0], true);
		for (x = [radius-size[0]/2, -radius+size[0]/2],
				 y = [radius-size[1]/2, -radius+size[1]/2]) {
			translate([x,y,0]) cylinder(r=radius, h=size[2], center=true);
		}
	}
	else {
		cube([size[0], size[1]-radius*2, size[2]-radius*2], center=true);
		cube([size[0]-radius*2, size[1], size[2]-radius*2], center=true);
		cube([size[0]-radius*2, size[1]-radius*2, size[2]], center=true);

		for (axis = [0:2]) {
			for (x = [radius-size[axis]/2, -radius+size[axis]/2],
					y = [radius-size[(axis+1)%3]/2, -radius+size[(axis+1)%3]/2]) {
				rotate(rot[axis]) 
					translate([x,y,0]) 
					cylinder(h=size[(axis+2)%3]-2*radius, r=radius, center=true);
			}
		}
		for (x = [radius-size[0]/2, -radius+size[0]/2],
				y = [radius-size[1]/2, -radius+size[1]/2],
				z = [radius-size[2]/2, -radius+size[2]/2]) {
			translate([x,y,z]) sphere(radius);
		}
	}
}
