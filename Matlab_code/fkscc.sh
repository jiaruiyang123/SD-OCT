#!/bin/bash -l

#$ -l h_rt=12:00:00
#$ -pe omp 16
#$ -N HumanBrain
#$ -j y

module load matlab/2018b
matlab -nodisplay -singleCompThread -r "fittingFijistitch; exit"

