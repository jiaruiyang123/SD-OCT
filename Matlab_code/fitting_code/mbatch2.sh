#!/bin/bash -l

#$ -l h_rt=24:00:00
#$ -pe omp 8
#$ -N HumanBrain
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "OCT_Scattering_2x; exit"

