#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
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
micromamba activate metawrap-env
# 1. Create an array of directories
#DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
#FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"
FILE=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/
# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}/metaspades"

if compgen -G "${OUTDIR}/bins/semibin/output_bins/*.gz" > /dev/null; then
    echo "Decompressing gzipped bins..."
    gzip -d "${OUTDIR}/bins/semibin/output_bins/"*.gz
fi

# 2. Remove previous refined bins
if [ -d "${OUTDIR}/bins/refined" ]; then
    echo "Removing old refined directory..."
    rm -rf "${OUTDIR}/bins/refined"
fi


/resnick/groups/enviromics/sal/tools/metaWRAP/bin/metawrap bin_refinement -t 30 -m 190 \
-o "${OUTDIR}/bins/refined/" \
-A "${OUTDIR}/bins/semibin/output_bins/" \
-B "${OUTDIR}/bins/metabat2/" \
-C "${OUTDIR}/bins/metadecoder/"
