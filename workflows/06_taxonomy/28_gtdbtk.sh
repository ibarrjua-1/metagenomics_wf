#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J binning_ref   # job name

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


eval "$(micromamba shell hook --shell bash)"
micromamba activate /resnick/groups/enviromics/sal/sharable_envs/gtdbtk-2.5.2
# 1. Create an array of directories

export GTDBTK_DATA_PATH=/resnick/groups/enviromics/databases/gtdbtk_r226/release226
gtdbtk classify_wf --genome_dir /resnick/groups/enviromics/sal/Caro_Soil_SIP/all_bins/dRep/dereplicated_genomes/ --out_dir /resnick/groups/enviromics/sal/Caro_Soil_SIP/all_bins/gtdbtk --extension .fa --cpus 32 --skip_ani_screen
