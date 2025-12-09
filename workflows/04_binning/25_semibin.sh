#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=56   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 1400GB   # memory per CPU core
#SBATCH -J comebin   # job name
# Notify at the beginning, end of job and on failure.


#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


eval "$(micromamba shell hook --shell bash)"
micromamba activate SemiBin

FILE=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR

# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
R1="/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/${SAMPLE_NAME}_R1.fastq.gz"
R2="/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/${SAMPLE_NAME}_R2.fastq.gz"

# base/output dirs
OUTDIR="${FILE%/}/metaspades"
ASSEMBLY="${OUTDIR}/scaffolds.fasta"

# paths for outputs
SAM="${OUTDIR}/assembly.sam"
BAM="${OUTDIR}/assembly.bam"
SORTED="${OUTDIR}/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"


SORTED_BAM_DIR="${OUTDIR}/sorted_bam"

# Make the directory if it doesn't exist
mkdir -p "$SORTED_BAM_DIR"

# Move the sorted BAM and its index files if they exist
SemiBin2 single_easy_bin --min-len 5000 --environment soil -i "${ASSEMBLY}" -b "$SORTED_BAM_DIR/assembly.sorted.bam" -o "${OUTDIR}/bins/semibin"
# 6) Run databinning with both SAM and sorted BAM
