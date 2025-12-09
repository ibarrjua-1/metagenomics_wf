#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J comebin   # job name
##SBATCH --array=0-7                 # Array range (update based on number of FASTA files)
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


# select sample for this array task
#SAMPLE_NAME="$(basename "${FILE}")"

# reads (auto-detect within the sample directory)
# base/output dirs
#OUTPUT_BASE="${FILE%/}"
#OUTDIR="${OUTPUT_BASE}"
#ASSEMBLY="${OUTDIR}/megahit/final.contigs.fa"
#eval "$(micromamba shell hook --shell bash)"
#micromamba activate samtools
#seqkit seq -m 1000 ${ASSEMBLY} > "${OUTDIR}/megahit/final.1000contigs.fa"

# paths for outputs
eval "$(micromamba shell hook --shell bash)"
micromamba activate kallisto 

kallisto index -t 32 -i /resnick/groups/enviromics/sal/Caro_Soil_SIP/functional_analysis/LR_genes.idx /resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/megahit/1000_prokka/*.ffn

kallisto quant \
  -i /resnick/groups/enviromics/sal/Caro_Soil_SIP/functional_analysis/LR_genes.idx \
  -o /resnick/groups/enviromics/sal/Caro_Soil_SIP/functional_analysis/JR71_7 \
  -t 32 \
  /resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies/JR71_7/JR71_7-R1.fastq.gz \
  /resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies/JR71_7/JR71_7-R2.fastq.gz
