#moved all the files into the same directory. Then ran to concatenate all the lanes together

#!/bin/bash

# Loop over all unique sample prefixes (before __L1)
for prefix in $(ls Caro-Soil-SIP-pooled__*L1-R1.fastq.gz | sed 's/__L1-R1.fastq.gz//' | sort | uniq); do
    echo "----"
    echo "Processing sample prefix: $prefix"

    # Combine R1 files
    R1_FILES=$(ls ${prefix}__L*-R1.fastq.gz 2>/dev/null)
    if [ -n "$R1_FILES" ]; then
        echo "Combining R1 files → ${prefix}_combined_R1.fastq.gz"
        cat $R1_FILES > ${prefix}_combined_R1.fastq.gz
    else
        echo "⚠️ No R1 files found for $prefix"
    fi

    # Combine R2 files
    R2_FILES=$(ls ${prefix}__L*-R2.fastq.gz 2>/dev/null)
    if [ -n "$R2_FILES" ]; then
        echo "Combining R2 files → ${prefix}_combined_R2.fastq.gz"
        cat $R2_FILES > ${prefix}_combined_R2.fastq.gz
    else
        echo "⚠️ No R2 files found for $prefix"
    fi
done

echo "✅ All samples processed."