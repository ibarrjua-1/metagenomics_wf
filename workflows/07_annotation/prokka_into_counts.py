#!/usr/bin/env python3
#Used after grep to find specific annotations from Prokka GFF output
"""
Convert Prokka GFF hits to a bin x protein count table
"""

import sys
import pandas as pd
from collections import defaultdict
import re

def parse_gff_line(line):
    """Extract bin and gene name from a GFF line"""
    fields = line.strip().split('\t')
    if len(fields) < 9:
        return None, None
    
    # Extract bin name from contig
    contig = fields[0]
    bin_name = contig.rsplit('_contig_', 1)[0] if '_contig_' in contig else contig
    
    # Extract gene name from attributes
    attributes = fields[8]
    
    # Try to get gene name first, then Name field
    gene_match = re.search(r'gene=([^;]+)', attributes)
    if gene_match:
        gene_name = gene_match.group(1)
    else:
        name_match = re.search(r'Name=([^;]+)', attributes)
        if name_match:
            gene_name = name_match.group(1)
        else:
            # Fallback to product
            product_match = re.search(r'product=([^;]+)', attributes)
            gene_name = product_match.group(1) if product_match else "unknown"
    
    # Remove numerical suffixes like _1, _2 for grouping similar genes
    gene_base = re.sub(r'_\d+$', '', gene_name)
    
    return bin_name, gene_base

def main():
    if len(sys.argv) > 1:
        input_file = sys.argv[1]
        with open(input_file, 'r') as f:
            lines = f.readlines()
    else:
        # Read from stdin
        lines = sys.stdin.readlines()
    
    # Count occurrences
    counts = defaultdict(lambda: defaultdict(int))
    
    for line in lines:
        if line.startswith('#') or not line.strip():
            continue
        
        bin_name, gene_name = parse_gff_line(line)
        if bin_name and gene_name:
            counts[bin_name][gene_name] += 1
    
    # Convert to DataFrame
    df = pd.DataFrame(counts).T.fillna(0).astype(int)
    
    # Sort for better readability
    df = df.sort_index()
    df = df[sorted(df.columns)]
    
    # Print table
    print(df.to_csv(sep='\t'))
    
    # Also save to file
    output_file = 'prokka_hits_table.tsv'
    df.to_csv(output_file, sep='\t')
    print(f"\nTable saved to: {output_file}", file=sys.stderr)

if __name__ == "__main__":
    main()