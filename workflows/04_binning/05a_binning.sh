#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J binning   # job name
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
micromamba activate databinner38

# Inputs
INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"

T=30

# build sample list (drop the _combined_R1 suffix)
FILES=($(ls ${INPUT_DIR}/*combined_R1.fastq.gz | sed 's/_combined_R1.fastq.gz//'))

# select sample for this array task
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}
SAMPLE_NAME=$(basename "$FILE")
R1="${FILE}_combined_R1.fastq.gz"
R2="${FILE}_combined_R2.fastq.gz"
OUTDIR="${OUTPUT_BASE}/${SAMPLE_NAME}"
ASSEMBLY="${OUTDIR}/scaffolds.fasta"


SAM="${OUTDIR}/assembly.sam"
BAM="${OUTDIR}/assembly.bam"
SORTED="${OUTDIR}/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"


# 6) Run databinning with both SAM and sorted BAM
/resnick/groups/enviromics/sal/tools/databinning/databinning/databinning.sh -m auto \
  -a "${ASSEMBLY}" -t 30 \
  -b "${SORTED}" \
  -s "${SAM}" \
  -o "${OUTDIR}/bins"
