#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=50   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 1490GB   # memory per CPU core
#SBATCH -J fastp   # job name
#SBATCH --array=0-7                # Array range (update based on number of FASTA files)

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# Create an array of R1 files

# 1. Create an array of directories
DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)

# 2. Select the directory based on SLURM_ARRAY_TASK_ID
DIR="${DIRS[$SLURM_ARRAY_TASK_ID]}"

# 3. Extract just the directory name (no path) using basename. SHoudl just be SR or 
SAMPLE=$(basename "$DIR")

# 4. Print to check
echo "Selected directory: $DIR"
echo "Sample name: $SAMPLE"

R1="${DIR}/${SAMPLE}-R1.fastq.gz"
R2="${DIR}/${SAMPLE}-R2.fastq.gz"

OUTDIR="${DIR}/megahit"

eval "$(micromamba shell hook --shell bash)"
micromamba activate megahit

megahit --continue --k-list 21,33,55,77,99,127 -m 0.99 -t 50 -1 "$R1" -2 "$R2" -o "$OUTDIR" 

echo "Done with ${SAMPLE}" 

