#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=03:00:00   # walltime
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


# inputs
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

eval "$(micromamba shell hook --shell bash)"
micromamba activate databinning


bowtie2-build "$ASSEMBLY" "$IDX_PREFIX"
bowtie2 -p "$T" -x "$IDX_PREFIX" -1 "$R1" -2 "$R2" -S "$SAM"

samtools view -@ "$T" -bS "$SAM" > "$BAM"
samtools sort -@ "$T" "$BAM" -o "$SORTED"
samtools index "$SORTED"
"