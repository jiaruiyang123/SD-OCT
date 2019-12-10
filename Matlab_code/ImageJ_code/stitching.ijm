//  Run the Grid/Collection stitching macro from the command line

// Run as:
//    ImageJ --headless -macro stitching.ijm "in_dir out_dir 2 2"
// example:
//    ImageJ --headless -macro stitching.ijm "/projectnb/bg-rcs/users/jiarui/fiji /projectnb/bg-rcs/users/jiarui/fiji 2 2"

// in_dir:  location of tiles
// out_dir: location to write stitched image
// X: number of files in X direction
// Y: number of files in Y direction

// TODO:  Location of plugins fed properly to ImageJ, headless mode
// Jiarui will have TIFFs ready to go




// Step 1:  Split up argument string into separate values
macro_args = getArgument;
search_index = 0 ;
space_index = indexOf(macro_args, " ", search_index) ;
in_dir = substring(macro_args, search_index, space_index) ;
search_index = space_index + 1 ;
space_index = indexOf(macro_args, " ", search_index) ;
out_dir = substring(macro_args, search_index, space_index) ;
search_index = space_index + 1 ;
space_index = indexOf(macro_args, " ", search_index) ;
num_X = substring(macro_args, search_index, space_index) ;
search_index = space_index + 1 ;
num_Y = substring(macro_args, search_index) ;

print(in_dir) ;
print(out_dir) ;
print(num_X) ;
print(num_Y) ;

stitch_cmd = "type=[Grid: column-by-column] order=[Up & Left] grid_size_x=" + num_X +
    " grid_size_y=" + num_Y + " tile_overlap=1 first_file_index_i=1 directory=" + 
    in_dir + " file_names={i}_aip.tif output_textfile_name=TileConfiguration.txt fusion_method=[Linear Blending] " +
    "regression_threshold=0.40 max/avg_displacement_threshold=2.40 absolute_displacement_threshold=2.60 compute_overlap " +
    "computation_parameters=[Save computation time (but use more RAM)] image_output=[Write to disk] " +
    "output_directory="+ out_dir ;

run("Grid/Collection stitching", stitch_cmd);
