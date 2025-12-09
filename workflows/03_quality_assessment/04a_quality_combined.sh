#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"

# Collect sample base names from R1 files
FILES=($(ls "${INPUT_DIR}"/*combined_R1.fastq.gz | sed 's/_combined_R1\.fastq\.gz$//'))

COMBINED="${OUTPUT_BASE}/quast_all_samples.tsv"

# First pass: gather existing reports
FIRST_REPORT=""
declare -a SAMPLES
declare -a REPORT_PATHS

for FILE in "${FILES[@]}"; do
    SAMPLE_NAME=$(basename "$FILE")
    OUTDIR="${OUTPUT_BASE}/${SAMPLE_NAME}"
    QUAST_OUT="${OUTDIR}/quast"
    REPORT="${QUAST_OUT}/report.tsv"

    if [[ -s "${REPORT}" ]]; then
        SAMPLES+=("${SAMPLE_NAME}")
        REPORT_PATHS+=("${REPORT}")
        [[ -z "${FIRST_REPORT}" ]] && FIRST_REPORT="${REPORT}"
    fi
done

if [[ -z "${FIRST_REPORT}" ]]; then
    echo "No report.txt files found under ${OUTPUT_BASE}/<sample>/quast/"
    exit 1
fi

# Build header from the first report
HEADER=$(awk -F'\t' 'NF==2 {print $1}' "${FIRST_REPORT}" | paste -sd $'\t' -)
echo -e "Sample\t${HEADER}" > "${COMBINED}"

# Write rows
for i in "${!SAMPLES[@]}"; do
    SAMPLE="${SAMPLES[$i]}"
    REPORT="${REPORT_PATHS[$i]}"
    VALUES=$(awk -F'\t' 'NF==2 {print $2}' "${REPORT}" | paste -sd $'\t' -)
    echo -e "${SAMPLE}\t${VALUES}" >> "${COMBINED}"
done

echo "Combined QUAST results written to: ${COMBINED}"
