#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=02:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J seqkit   # job name

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# Create an array of R1 files
eval "$(micromamba shell hook --shell bash)"
micromamba activate samtools


seqkit stats -j 30 /resnick/groups/enviromics/data/Caro_Soil_SIP_raw_data/*.fastq.gz > seqkit_stats.txt
