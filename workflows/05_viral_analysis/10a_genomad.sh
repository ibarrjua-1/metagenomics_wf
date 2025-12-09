#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"

# Where CheckV put its outputs (adjust if your layout differs)
CHECKV_REL="genomad/scaffolds_summary/checkv/quality_summary.tsv"

COMBINED="${OUTPUT_BASE}/checkv_all_samples.tsv"

# Discover sample bases from *_combined_R1.fastq.gz
mapfile -t FILES < <(ls -1 "${INPUT_DIR}"/*combined_R1.fastq.gz | sed 's/_combined_R1\.fastq\.gz$//' | sort)

FIRST_HEADER=""
: > "${COMBINED}"  # truncate

for FILE in "${FILES[@]}"; do
  SAMPLE_NAME="$(basename "$FILE")"
  REPORT="${OUTPUT_BASE}/${SAMPLE_NAME}/${CHECKV_REL}"
  [[ ! -s "$REPORT" ]] && { echo "[warn] Missing CheckV for ${SAMPLE_NAME}"; continue; }

  # Grab header from the first report and write once (with 'Sample' prefix)
  if [[ -z "$FIRST_HEADER" ]]; then
    FIRST_HEADER="$(head -n1 "$REPORT")"
    echo -e "Sample\t${FIRST_HEADER}" > "${COMBINED}"
  fi

  # Append rows with 'Sample' column
  awk -v s="$SAMPLE_NAME" 'BEGIN{FS=OFS="\t"} NR>1{print s,$0}' "$REPORT" >> "${COMBINED}"
done

echo "Wrote: ${COMBINED}"




#!/usr/bin/env bash
set -euo pipefail

COMBINED="/resnick/groups/enviromics/sal/Caro_Soil_SIP/checkv_all_samples.tsv"
LONG="/resnick/groups/enviromics/sal/Caro_Soil_SIP/checkv_quality_long.tsv"

# Build long table: Sample \t checkv_quality
# Dynamically find the column index of 'checkv_quality' from the header
{
  read -r header
  IFS=$'\t' read -r -a cols <<< "$header"
  qidx=0
  for i in "${!cols[@]}"; do
    [[ "${cols[$i]}" == "checkv_quality" ]] && qidx=$((i+1))
  done
  if [[ $qidx -eq 0 ]]; then
    echo "Could not find 'checkv_quality' column in ${COMBINED}" >&2
    exit 1
  fi

  echo -e "Sample\tcheckv_quality"
  while IFS=$'\t' read -r -a row; do
    sample="${row[0]}"
    qual="${row[$qidx]}"
    [[ -z "$qual" ]] && qual="NA"
    echo -e "${sample}\t${qual}"
  done
} < "${COMBINED}" > "${LONG}"

echo "Wrote: ${LONG}"

# Quick overall counts (across all samples)
echo -e "\n== Overall counts (checkv_quality) =="
awk -F'\t' 'NR>1 {c[$2]++} END{for(k in c) printf "%s\t%d\n",k,c[k]}' "${LONG}" | sort
