#!/usr/bin/env bash
set -euo pipefail

# ===== Config =====
ROOT="/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly"
COMBINED="${ROOT}/quast_combined.tsv"

# Collect immediate subdirectories as samples
mapfile -t DIRS < <(find "$ROOT" -mindepth 1 -maxdepth 1 -type d | sort)

FIRST_REPORT=""
declare -a SAMPLES
declare -a REPORT_PATHS

# Gather existing QUAST reports
for DIR in "${DIRS[@]}"; do
  SAMPLE_NAME="$(basename "$DIR")"
  REPORT="${DIR}/quast/report.tsv"
  if [[ -s "$REPORT" ]]; then
    SAMPLES+=("$SAMPLE_NAME")
    REPORT_PATHS+=("$REPORT")
    [[ -z "$FIRST_REPORT" ]] && FIRST_REPORT="$REPORT"
  fi
done

if [[ -z "$FIRST_REPORT" ]]; then
  echo "No report.tsv files found under ${ROOT}/*/quast/"
  exit 1
fi

# Build canonical header (left column of FIRST_REPORT, skipping 'Assembly')
# Strip possible CRs.
mapfile -t HEADER_ARR < <(awk -F'\t' 'NF==2 { gsub(/\r/,"",$1) } $1!="Assembly"{print $1}' "$FIRST_REPORT")

# Write combined table
{
  # Header line
  printf "Sample"
  for h in "${HEADER_ARR[@]}"; do
    printf "\t%s" "$h"
  done
  printf "\n"

  # Rows per sample in the same header order
  for i in "${!SAMPLES[@]}"; do
    SAMPLE="${SAMPLES[$i]}"
    REPORT="${REPORT_PATHS[$i]}"

    # Build a key->value map from this report (skip 'Assembly', strip CRs)
    declare -A KV=()
    while IFS=$'\t' read -r k v; do
      [[ -z "${k:-}" ]] && continue
      [[ "$k" == "Assembly" ]] && continue
      # Strip any trailing CRs (Windows line endings)
      k="${k%$'\r'}"
      v="${v%$'\r'}"
      KV["$k"]="$v"
    done < "$REPORT"

    # Print in header order, NA for missing keys
    printf "%s" "$SAMPLE"
    for h in "${HEADER_ARR[@]}"; do
      printf "\t%s" "${KV[$h]:-NA}"
    done
    printf "\n"

    unset KV
  done
} > "$COMBINED"

echo "Combined QUAST results written to: $COMBINED"
