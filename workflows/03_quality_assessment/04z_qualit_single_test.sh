#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=1:00:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J quast   # job name

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR

eval "$(micromamba shell hook --shell bash)"


micromamba activate quast
DIR=/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/metaspades_errorcorr
ASSEMBLY="${DIR}/scaffolds.fasta"
QUAST_OUT="${DIR}/quast"

echo "Processing sample: ${DIR}"
echo "Assembly: ${ASSEMBLY}"
echo "QUAST out: ${QUAST_OUT}"

    # Run QUAST
quast \
-o "${QUAST_OUT}" \
-t 30 \
--min-contig 1000 \
"${ASSEMBLY}"

echo "Results: ${QUAST_OUT}"
