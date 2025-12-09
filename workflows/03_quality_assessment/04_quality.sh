
eval "$(micromamba shell hook --shell bash)"
micromamba activate quast

#!/usr/bin/env bash
set -euo pipefail

# ===== Paths =====
INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"

# Collect sample base names from R1 files
FILES=($(ls "${INPUT_DIR}"/*combined_R1.fastq.gz | sed 's/_combined_R1.fastq.gz//'))

# Threads: prefer SLURM_CPUS_PER_TASK if set, else default to 30
THREADS="${SLURM_CPUS_PER_TASK:-30}"

for FILE in "${FILES[@]}"; do
    SAMPLE_NAME=$(basename "$FILE")
    OUTDIR="${OUTPUT_BASE}/${SAMPLE_NAME}"
    ASSEMBLY="${OUTDIR}/scaffolds.fasta"
    QUAST_OUT="${OUTDIR}/quast"

    echo "------------------------------------"
    echo "Processing sample: ${SAMPLE_NAME}"
    echo "Assembly: ${ASSEMBLY}"
    echo "QUAST out: ${QUAST_OUT}"
    echo "------------------------------------"

    # If assembly doesn't exist, skip
    if [[ ! -s "${ASSEMBLY}" ]]; then
        echo "No assembly found at ${ASSEMBLY} — skipping ${SAMPLE_NAME}"
        continue
    fi

    # Skip if QUAST already ran
    if [[ -s "${QUAST_OUT}/report.txt" ]]; then
        echo "Skipping ${SAMPLE_NAME} — QUAST results already exist"
        continue
    fi

    # Run QUAST
    echo "Running QUAST for ${SAMPLE_NAME}..."
    quast \
        -o "${QUAST_OUT}" \
        -t "${THREADS}" \
        --min-contig 1000 \
        "${ASSEMBLY}"

    echo "QUAST done for ${SAMPLE_NAME}"
    echo "Results: ${QUAST_OUT}"
done