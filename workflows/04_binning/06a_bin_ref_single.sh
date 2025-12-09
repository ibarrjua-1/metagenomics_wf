#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=24:00:00   # walltime
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
# Inputs
INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"

# build sample list (drop the _combined_R1 suffix)
FILES=($(ls ${INPUT_DIR}/*combined_R1.fastq.gz | sed 's/_combined_R1.fastq.gz//'))

# select sample for this array task
FILE=${FILES[1]}
SAMPLE_NAME=$(basename "$FILE")
OUTDIR="${OUTPUT_BASE}/${SAMPLE_NAME}"


/resnick/groups/enviromics/sal/tools/metaWRAP/bin/metawrap bin_refinement -t 30 -m 190 \
-o "${OUTDIR}/bins/bin_refined/" \
-A "${OUTDIR}/bins/comebin_result/bins_dir/" \
-B "${OUTDIR}/bins//metabat2_result/bins_dir/" \
-C "${OUTDIR}/bins//metadecoder_result/bins_dir/"
