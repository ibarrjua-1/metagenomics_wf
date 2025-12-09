#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=12:00:00   # walltime
#SBATCH --ntasks=28   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J checkv   # job name
##SBATCH --array=0-7                 # Array range (update based on number of FASTA files)

#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# Inputs
# 1. Create an array of directories
DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"

# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"

eval "$(micromamba shell hook --shell bash)"
micromamba activate checkv

checkv end_to_end /resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JS/vibrant/VIBRANT_final.contigs/VIBRANT_phages_final.contigs/final.contigs.phages_combined.fna /resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JS/vibrant/checkv -d /resnick/groups/enviromics/databases/checkv-db-v1.5/
