#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J binning_prep   # job name

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR

#!/usr/bin/env bash
set -euo pipefail

# 1. Create an array of directories
#DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
#FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"
FILE=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR

# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
R1="/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/${SAMPLE_NAME}_R1.fastq.gz"
R2="/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/${SAMPLE_NAME}_R2.fastq.gz"
T=32

# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}/metaspades"
ASSEMBLY="${OUTDIR}/scaffolds.fasta"

# paths for outputs
SAM="${OUTDIR}/assembly.sam"
BAM="${OUTDIR}/assembly.bam"
SORTED="${OUTDIR}/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"

echo "${OUTDIR}"
echo "${ASSEMBLY}"
echo "${R1}"
echo "${R2}"
echo "${SAM}"
echo "${BAM}"

# sanity checks
[[ -f "${ASSEMBLY}" ]] || { echo "Missing assembly: ${ASSEMBLY}" >&2; exit 1; }
[[ -f "${R1}" && -f "${R2}" ]] || { echo "Missing reads in ${FILE} (expected *_R1*.fastq.gz and *_R2*.fastq.gz)" >&2; exit 1; }

# ensure output dir exists
mkdir -p "${OUTDIR}"

eval "$(micromamba shell hook --shell bash)"
micromamba activate databinning

bowtie2-build "${ASSEMBLY}" "${IDX_PREFIX}"
bowtie2 -p "${T}" -x "${IDX_PREFIX}" -1 "${R1}" -2 "${R2}" -S "${SAM}"

samtools view -@ "${T}" -bS "${SAM}" -o "${BAM}"
samtools sort -@ "${T}" "${BAM}" -o "${SORTED}"
samtools index "${SORTED}"
