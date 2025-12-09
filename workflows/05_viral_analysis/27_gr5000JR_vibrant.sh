#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 500GB   # memory per CPU core
#SBATCH -J comebin   # job name
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
DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/

# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"
ASSEMBLY="${OUTDIR}/megahit/final_gt5000.contigs.fa"

# paths for outputs
SAM="${OUTDIR}/assembly.sam"
BAM="${OUTDIR}/assembly.bam"
SORTED="${OUTDIR}/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"


eval "$(micromamba shell hook --shell bash)"
micromamba activate vibrant-env

#VIBRANT is installed in /sal/tools directory. It is called wtih the command VIBRANT_run.py
python3 /resnick/groups/enviromics/sal/tools/VIBRANT/VIBRANT_run.py \
  -i "${ASSEMBLY}" \
  -folder "${OUTDIR}/vibrant5000" \
  -t 32 \


