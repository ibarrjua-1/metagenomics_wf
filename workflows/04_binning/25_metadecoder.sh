#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J metadecoder    # job name

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


eval "$(micromamba shell hook --shell bash)"
micromamba activate metadecoder

# Inputs
# 1. Create an array of directories
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


mkdir -p "${OUTDIR}/bins"
# 6) Run databinning with both SAM and sorted BAM

metadecoder coverage -b "${SORTED}" -o "${OUTDIR}/METADECODER.COVERAGE"

metadecoder seed --threads 30 -f "${ASSEMBLY}" -o "${OUTDIR}/METADECODER.SEED"

metadecoder cluster -f "${ASSEMBLY}" -c "${OUTDIR}/METADECODER.COVERAGE" -s "${OUTDIR}/METADECODER.SEED" -o "${OUTDIR}/bins/METADECODER_bin"
