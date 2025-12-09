#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=1:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J dram_2_run   # job name
#SBATCH --array=0-7                 # Array range (update based on number of FASTA files)

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


#from inside the /sal/tools/DRAM directory

eval "$(micromamba shell hook --shell bash)"
micromamba activate env_nf 

module load apptainer


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

#nextflow run /resnick/groups/enviromics/sal/tools/WrightonLabCSU/DRAM \
#  --input_fasta "${OUTDIR}/genomad/cobra/checkv/" --fasta_fmt 'filtered_seqs.fasta' \
#  --outdir "${OUTDIR}/genomad/cobra/dramv/" \
#  --threads 30 -profile singularity \
#  --call --rename --annotate \
#  --use_uniref --use_merops --use_viral --use_camper \
#  --use_kofam --use_dbcan --use_methyl --use_canthyd --use_vog --use_fegenie --use_sulfur \
#  --distill_topic default --distill_ecosystem 'eng_sys' \
#  --slurm_node main -with-report -with-trace -with-timeline
#
##to distill run inside the dram output folder
##I had to change a bunch of the source coce of the distill.py script to make it work
cd "${OUTDIR}/genomad/cobra/dramv/"

micromamba activate env_nf

python /resnick/groups/enviromics/sal/tools/WrightonLabCSU/DRAM/bin/distill.py -i RAW/raw-annotations.tsv   --distil_topics default   --distil_ecosystem eng_sys,ag

awk -F'\t' '$NF != 0' summarized_genomes.tsv > filtered.tsv
