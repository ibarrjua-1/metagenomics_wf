#!/bin/sh
# Submit this script with: sbatch <this-filename>
#SBATCH --time=00:30:00   # walltime
#SBATCH --ntasks=30   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J quality   # job name
eval "$(micromamba shell hook --shell bash)"
micromamba activate quast

#!/usr/bin/env bash
set -euo pipefail

# ===== Paths =====
# 1. Create an array of directories
DIRS=(/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/*/)


for DIR in "${DIRS[@]}"; do
    
    ASSEMBLY="${DIR}/megahit/final.contigs.fa"
    QUAST_OUT="${DIR}/quast"

    echo "------------------------------------"
    echo "Processing sample: ${DIR}"
    echo "Assembly: ${ASSEMBLY}"
    echo "QUAST out: ${QUAST_OUT}"
    echo "------------------------------------"

    # If assembly doesn't exist, skip
    if [[ ! -s "${ASSEMBLY}" ]]; then
        continue
    fi

    # Skip if QUAST already ran
    if [[ -s "${QUAST_OUT}/report.txt" ]]; then
        continue
    fi

    # Run QUAST
    quast \
        -o "${QUAST_OUT}" \
        -t 30 \
        --min-contig 1000 \
        "${ASSEMBLY}"

    echo "Results: ${QUAST_OUT}"
done
