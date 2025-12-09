#!/usr/bin/env bash

# === USER CONFIG ===
INPUT_DIR="/resnick/groups/enviromics/data/Caro_Soil_SIP_raw_data"
OUTPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/concat"
# ====================

mkdir -p "$OUTPUT_DIR"

echo "Combining FASTQs from: $INPUT_DIR"
echo "Writing combined files to: $OUTPUT_DIR"
echo

# Find sample prefixes based on L1 R1 files in INPUT_DIR only (no subdirs)
for prefix in $(
    find "$INPUT_DIR" -maxdepth 1 -type f \
        -name "Caro-Soil-SIP-pooled__*__L1_*_R1_001.fastq.gz" \
        | sed 's|.*/||' \
        | sed -E 's/__L1_.*_R1_001.fastq.gz$//' \
        | sort -u
); do
    echo "========================================"
    echo "Processing sample prefix: $prefix"

    # ----------------
    # Combine R1 files
    # ----------------
    R1_FILES=$(find "$INPUT_DIR" -maxdepth 1 -type f -name "${prefix}__L*_R1_001.fastq.gz" | sort)

    if [ -n "$R1_FILES" ]; then
        echo "R1 lanes to combine:"
        printf '   %s\n' $R1_FILES

        OUT_R1="${OUTPUT_DIR}/${prefix}_combined_R1.fastq.gz"
        echo "→ Writing combined R1 to: $OUT_R1"
        cat $R1_FILES > "$OUT_R1"
    else
        echo "⚠️ No R1 files found for prefix: $prefix"
    fi

    echo

    # ----------------
    # Combine R2 files
    # ----------------
    R2_FILES=$(find "$INPUT_DIR" -maxdepth 1 -type f -name "${prefix}__L*_R2_001.fastq.gz" | sort)

    if [ -n "$R2_FILES" ]; then
        echo "R2 lanes to combine:"
        printf '   %s\n' $R2_FILES

        OUT_R2="${OUTPUT_DIR}/${prefix}_combined_R2.fastq.gz"
        echo "→ Writing combined R2 to: $OUT_R2"
        cat $R2_FILES > "$OUT_R2"
    else
        echo "⚠️ No R2 files found for prefix: $prefix"
    fi

    echo
done

echo "========================================"
echo "Done! All samples combined."
