#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=01:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J fastp   # job name
#SBATCH --array=0-71                 # Array range (update based on number of FASTA files)

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# Create an array of R1 files
R1_FILES=($(ls /resnick/groups/enviromics/data/Caro_Soil_SIP_raw_data/Caro-Soil-SIP-pooled*R1_001.fastq.gz))

# Get R1 file for this array index
R1=${R1_FILES[$SLURM_ARRAY_TASK_ID]}
R2=${R1/R1_001.fastq.gz/R2_001.fastq.gz}

# Extract sample base name
SAMPLE=$(echo $R1 | sed 's/_S[0-9]\+_L00[0-9]_R1_001.fastq.gz//')
SAMPLE_NAME=$(basename "$R1" | sed 's/_S[0-9]\+_L00[0-9]_R1_001.fastq.gz//')
OUTPUT="/resnick/groups/enviromics/sal/Caro_Soil_SIP/$SAMPLE_NAME"

# Make sure output directory exists
mkdir -p "$OUTPUT"

echo "[$SLURM_ARRAY_TASK_ID] Processing $SAMPLE"
echo "  R1: $R1"
echo "  R2: $R2"

/resnick/groups/enviromics/sal/tools/fastp -i "$R1" -I "$R2" -z 1 \
    -5 -3 -e 15 -q 20 -u 40 -c \
    -h "$OUTPUT/$SAMPLE_NAME-fastp.html" -w 30 \
    -o "$OUTPUT/$SAMPLE_NAME-R1.fastq.gz" -O "$OUTPUT/$SAMPLE_NAME-R2.fastq.gz"

echo "[$SLURM_ARRAY_TASK_ID] Done with $SAMPLE"

