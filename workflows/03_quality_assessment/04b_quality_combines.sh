#!/usr/bin/env bash
set -euo pipefail

INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"
COMBINED="${OUTPUT_BASE}/quast_all_samples.tsv"

# Collect sample base names from R1 files
mapfile -t FILES < <(ls -1 "${INPUT_DIR}"/*combined_R1.fastq.gz | sed 's/_combined_R1\.fastq\.gz$//' | sort)

FIRST_REPORT=""
declare -a SAMPLES
declare -a REPORT_PATHS

# Gather existing QUAST reports
for FILE in "${FILES[@]}"; do
  SAMPLE_NAME=$(basename "$FILE")
  REPORT="${OUTPUT_BASE}/${SAMPLE_NAME}/quast/report.tsv"
  if [[ -s "$REPORT" ]]; then
    SAMPLES+=("$SAMPLE_NAME")
    REPORT_PATHS+=("$REPORT")
    [[ -z "$FIRST_REPORT" ]] && FIRST_REPORT="$REPORT"
  fi
done

if [[ -z "$FIRST_REPORT" ]]; then
  echo "No report.tsv files found under ${OUTPUT_BASE}/<sample>/quast/"
  exit 1
fi

# Build canonical header (skip 'Assembly')
mapfile -t HEADER_ARR < <(awk -F'\t' 'NF==2 && $1!="Assembly" {print $1}' "$FIRST_REPORT")
{
  printf "Sample"
  for h in "${HEADER_ARR[@]}"; do
    printf "\t%s" "$h"
  done
  printf "\n"

  # For each sample, print values in the same header order
  for i in "${!SAMPLES[@]}"; do
    SAMPLE="${SAMPLES[$i]}"
    REPORT="${REPORT_PATHS[$i]}"

    # Build key->value map, skipping 'Assembly'. Also strip CR if present.
    awk -v sample="$SAMPLE" -v OFS="\t" -v RS='\n' -v ORS='\n' '
      BEGIN{
        # Load header order from ENV passed via -v isn’t convenient; we’ll
        # print only the first token now and append values later in shell.
      }
    ' /dev/null >/dev/null  # placeholder (we’ll fill via shell below)

    # Use awk to create a temporary TSV "key\tvalue" (skip Assembly; strip CR)
    TMP_KV=$(awk -F'\t' 'NF==2 && $1!="Assembly" {
                            gsub(/\r$/,"",$1); gsub(/\r$/,"",$2);
                            print $1 "\t" $2
                          }' "$REPORT")

    # Build an assoc array in bash for this sample
    declare -A KV=()
    while IFS=$'\t' read -r k v; do
      [[ -z "${k:-}" ]] && continue
      KV["$k"]="$v"
    done <<< "$TMP_KV"

    # Print row in header order (NA if missing)
    printf "%s" "$SAMPLE"
    for h in "${HEADER_ARR[@]}"; do
      printf "\t%s" "${KV[$h]:-NA}"
    done
    printf "\n"

    # clear assoc array for next sample
    unset KV
    declare -A KV=()
  done
} > "$COMBINED"

echo "Combined QUAST results written to: $COMBINED"
