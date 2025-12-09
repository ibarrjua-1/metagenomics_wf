#!/bin/bash
# Submit this sciript with: sbatch <this-filename>
#SBATCH --time=02:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J kraken2byiuld   # job name
# Notify at the beginning, end of job and on failure.
cd /resnick/groups/enviromics/databases

tar -xvzf k2_standard_20251015.tar.gz \
    -C /resnick/groups/enviromics/databases/kraken2_db/
