#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J prokka_ls   # job name
#SBATCH --output=/resnick/groups/enviromics/sal/metagenomics_wf/logs/251211_prokka_LS.out
# Notify at the beginning, end of job and on failure.


#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# Inputs
# 1. Create an array of directories
#DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
#FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"
FILE=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LS/

# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"
ASSEMBLY="${OUTDIR}/megahit/final.contigs.fa"
#eval "$(micromamba shell hook --shell bash)"
#micromamba activate samtools
#seqkit seq -m 1000 ${ASSEMBLY} > "${OUTDIR}/megahit/final.1000contigs.fa"

# paths for outputs
eval "$(micromamba shell hook --shell bash)"
micromamba activate prokka 

prokka --outdir "${OUTDIR}/megahit/1000_prokka" --metagenome --cpus 32 "${OUTDIR}/megahit/final.1000contigs.fa" --force
