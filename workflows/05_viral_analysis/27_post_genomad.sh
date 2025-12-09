#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J comebin   # job name
#SBATCH --array=0-7                 # Array range (update based on number of FASTA files)
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
DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
FILE="${DIRS[$SLURM_ARRAY_TASK_ID]}"


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
SORTED="${OUTDIR}/sorted_bam/assembly.sorted.bam"
IDX_PREFIX="${ASSEMBLY}_idx"

OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"


OUTPUT_BASE="${FILE%/}"
OUTDIR="${OUTPUT_BASE}"

eval "$(micromamba shell hook --shell bash)"

micromamba activate coverm

#coverm contig --methods metabat --bam-files "${SORTED}" -o "${OUTDIR}/coverm.out"

#awk -F'\t' 'NR>1 {print $1 "\t" $3}' "${OUTDIR}/coverm.out" > "${OUTDIR}/coverm_fixed.tsv"

#micromamba activate cobra

#cobra-meta -q "${OUTDIR}/genomad/final.contigs_summary/final.contigs_virus.fna" \
#    -f "${OUTDIR}/megahit/final.contigs.fa" \
#    -a megahit \
#    -c "${OUTDIR}/coverm_fixed.tsv" \
#    -m "${OUTDIR}/sorted_bam/assembly.sorted.bam" \
#    -mink 21 -maxk 127 \
#    -o "${OUTDIR}/genomad/cobra"
#rm -rf "${OUTDIR}/genomad/cobra/combined.fasta"
#cat ${OUTDIR}/genomad/cobra/*.fasta > "${OUTDIR}/genomad/cobra/combined.fa"
#
#micromamba activate checkv
#rm -rf "${OUTDIR}/genomad/cobra/checkv"
#
#checkv end_to_end "${OUTDIR}/genomad/cobra/combined.fa" \
#    "${OUTDIR}/genomad/cobra/checkv" \
#    -t 32 \
#    -d /resnick/groups/enviromics/databases/checkv-db-v1.5/
#
#awk -F'\t' 'NR==1 || ($2 > 1000 && $0 !~ /Low-quality/ && $0 !~ /Not-determined/)' \
#    "${OUTDIR}/genomad/cobra/checkv/quality_summary.tsv" > "${OUTDIR}/genomad/cobra/checkv/filtered.tsv"
#
micromamba activate samtools

cut -f1 "${OUTDIR}/genomad/cobra/checkv/filtered.tsv" | tail -n +2 > "${OUTDIR}/genomad/cobra/checkv/ids.txt"
seqkit grep -f "${OUTDIR}/genomad/cobra/checkv/ids.txt" "${OUTDIR}/genomad/cobra/checkv/viruses.fna" > \
    "${OUTDIR}/genomad/cobra/checkv/filtered_seqs.fasta"

micromamba activate vs2

virsorter run --prep-for-dramv \
    -d /resnick/groups/enviromics/databases/virsorter2 \
    -i "${OUTDIR}/genomad/cobra/checkv/filtered_seqs.fasta" \
    -w "${OUTDIR}/genomad/virsorter2" \
    -j 32 --min-length 1000
