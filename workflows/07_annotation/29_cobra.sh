#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J cobra  # job name
# Notify at the beginning, end of job and on failure.
#SBATCH --array=0-7                 # Array range (update based on number of FASTA files)

#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# Inputs
# 1. Create an array of directories
DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"
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
SORTED="${OUTDIR}/sorted_bam/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"


eval "$(micromamba shell hook --shell bash)"
micromamba activate cobra

cobra-meta -q ${OUTDIR}/genomad/final.contigs_summary/final.contigs_virus.fna -f ${OUTDIR}/megahit/final.contigs.fa -a megahit -c ${OUTDIR}/coverm_fixed.tab.tsv -m ${OUTDIR}/sorted_bam/assembly.sorted.bam -mink 21 -maxk 127 -o ${OUTDIR}/genomad/cobra

micromamba activate checkv

checkv end_to_end "${OUTDIR}/genomad/cobra/final.contigs.new.fa" "${OUTDIR}/virsorter2/checkv" -d /resnick/groups/enviromics/databases/checkv-db-v1.5/


