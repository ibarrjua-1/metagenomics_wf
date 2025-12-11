#!/bin/bash

# Loop through all bin fasta files
for bin_file in bin.*.fa; do
    # Get the bin name without .fa extension
    bin_name=$(basename "$bin_file" .fa)
    
    # Create temporary file
    temp_file="${bin_file}.tmp"
    
    # Rename contigs with awk
    awk -v bn="$bin_name" '/^>/ {print ">" bn "_contig_" ++count; next} {print}' "$bin_file" > "$temp_file"
    
    # Replace original file
    mv "$temp_file" "$bin_file"
    
    echo "Processed $bin_file"
done
