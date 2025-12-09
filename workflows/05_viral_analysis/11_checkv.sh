#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=1:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J binning_prep   # job name
#SBATCH --array=0-23                 # Array range (update based on number of FASTA files)

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR
eval "$(micromamba shell hook --shell bash)"
micromamba activate checkv

# Inputs
INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"

# build sample list (drop the _combined_R1 suffix)
FILES=($(ls ${INPUT_DIR}/*combined_R1.fastq.gz | sed 's/_combined_R1.fastq.gz//'))

# select sample for this array task
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
SAMPLE_NAME=$(basename "$FILE")
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"

OUTDIR="${OUTPUT_BASE}/${SAMPLE_NAME}"
ASSEMBLY="${OUTDIR}/scaffolds.fasta"
GENOMAD="${OUTDIR}/genomad"


# 6) Run databinning with both SAM and sorted BAM
checkv end_to_end "${GENOMAD}/scaffolds_summary/scaffolds_virus.fna" "${GENOMAD}/scaffolds_summary/checkv" -d /resnick/groups/enviromics/databases/checkv-db-v1.5/
