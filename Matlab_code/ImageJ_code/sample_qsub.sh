#!/bin/bash -l

# Qsub settings

#$ -P project
#$ -m ea
#$ -pe omp 8


# Example of running the ImageJ Grid/Collection Stitching on directory of
# tiled images using a queue job.

#  Somewhere the final output dir needs to be set, presumably
# this is known from how Matlab was run. This should be unique for
# each data set/Matlab run.

# Example:
FINAL_OUTPUT_DIR=/projectnb/npbssmic/ns/Jiarui/0126volume/stitching/vol1/


module load fiji/2015.12.22


### Run the matlab script
# module load matlab
# matlab...
# Have Matlab write out the name of the directory the tile images are
# in to a file, say $TMPDIR/tile_dir.txt
# Format of file_dir.txt.  Note there's no spaces around the = :
#
#  TILE_DIR=/scratch/job.3444359/image_tiles
#  NUM_X=17
#  NUM_Y=17

# Execute as though it's a bash script - this is the easiest way
# to read it in!
source $TMPDIR/tile_dir.txt

# Make it if it doesn't exist
mkdir -p $FINAL_OUTPUT_DIR

# The combined file will temporarily be written to the 
# $TMPDIR then moved to $FINAL_OUTPUT_DIR
TEMP_OUTPUT_DIR=$TMPDIR/combined
mkdir -p $TEMP_OUTPUT_DIR

# Now run the ImageJ Grid/Collection script
# use libsysconfcpus to limit the # of CPUs used by ImageJ 
# a limit of 2 CPUs seems to work well
export PATH=/project/npbssmic/software/libsysconfcpus/bin:$PATH
export LD_LIBRARY_PATH=/project/npbssmic/software/libsysconfcpus/lib:$LD_LIBRARY_PATH
sysconfcpus -n 2 ImageJ --headless -macro /projectnb/npbssmic/ns/Jiarui/code/ImageJ_code/stitching.ijm "$TILE_DIR $TEMP_OUTPUT_DIR $NUM_X $NUM_Y"

# Move the combined image from the $TEMP_OUTPUT_DIR to the $FINAL_OUTPUT_DIR
# and rename it along the way.  The plugin likes to call the image "img_t1_z1_c1"
# Use a wildcard to make this easier
for tiff in $TEMP_OUTPUT_DIR/img* ; do
    # the basename command strips the directory from the filename
    mv "$tiff" $FINAL_OUTPUT_DIR/$(basename "$tiff").tif
done

mv $TILE_DIR/*txt $FINAL_OUTPUT_DIR
