#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=02:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J kraken2   # job name
#SBATCH --array=0-23                # Array range (update based on number of FASTA files)

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"


# select sample for this array task
SAMPLE="$(basename "${FILE}")"

R1="${FILE}/${SAMPLE}-R1.fastq.gz"
R2="${FILE}/${SAMPLE}-R2.fastq.gz"

# reads (auto-detect within the sample directory)
# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"


eval "$(micromamba shell hook --shell bash)"
micromamba activate kraken2

/resnick/groups/enviromics/sal/tools/kraken2/k2 classify --db /groups/enviromics/databases/kraken2 --threads 32 --output "${OUTDIR}/kraken2" --paired $R1 $R2
