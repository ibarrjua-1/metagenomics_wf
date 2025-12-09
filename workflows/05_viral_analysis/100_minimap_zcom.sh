#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=04:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J checkv   # job name
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
FILE=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/

# select sample for this array task
SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
# base/output dirs
OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"
ASSEMBLY="${OUTDIR}/megahit/final.contigs.fa"

# paths for outputs
SAM="${OUTDIR}/assembly.sam"
BAM="${OUTDIR}/assembly.bam"
SORTED="${OUTDIR}/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"

R1="${OUTDIR}/${SAMPLE_NAME}-R1.fastq.gz"
R2="${OUTDIR}/${SAMPLE_NAME}-R2.fastq.gz"

GENOMAD="${OUTDIR}/genomad"
eval "$(micromamba shell hook --shell bash)"
micromamba activate minimap2

echo "[$(date)] Starting minimap2 mapping..."
minimap2 -x sr -t 32 -a /resnick/groups/enviromics/sal/phages/zengler_soil_syncom/zengler_soil_syncom.fna $R1 $R2 \
  | samtools sort -@8 -o ${OUTDIR}/reads_vs_zcom.bam
echo "[$(date)] Mapping complete."

echo "[$(date)] Indexing BAM..."
samtools index  ${OUTDIR}/reads_vs_zcom.bam
echo "[$(date)] Indexing complete."

# Optional: quick alignment summary
echo "[$(date)] Summary:"
samtools flagstat  ${OUTDIR}/reads_vs_zcom.bam | tee mapping_summary.txt

echo "[$(date)] Done!"
