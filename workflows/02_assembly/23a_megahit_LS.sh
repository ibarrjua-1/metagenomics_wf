#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=72:00:00   # walltime
#SBATCH --ntasks=50   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 700GB   # memory per CPU core
#SBATCH -J assembly_LS   # job name

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


# 2. Select the directory
DIR=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LS

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

megahit --k-list 25,33,55,77,99,127 -m 0.99 -t 50 -1 "$R1" -2 "$R2" -o "$OUTDIR" --continue

echo "Done with ${SAMPLE}" 

