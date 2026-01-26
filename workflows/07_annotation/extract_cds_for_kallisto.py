# extract_cds_for_kallisto.py
import pandas as pd
from Bio import SeqIO

# Load your Prokka annotations
prokka = pd.read_csv("PROKKA_11252025.tsv", sep='\t')

# Filter CDSs with COG
cds_with_cog = prokka[(prokka['ftype'] == 'CDS') & (prokka['COG'].notna())]

print(f"CDSs with COG: {len(cds_with_cog)}")

# Save locus tags
cds_with_cog['locus_tag'].to_csv('locus_tags_with_cog.txt', 
                                  index=False, header=False)

# Extract these sequences from prokka .ffn file
locus_tags = set(cds_with_cog['locus_tag'])
with open('cds_with_cog.fna', 'w') as out:
    for record in SeqIO.parse('PROKKA_11252025.ffn', 'fasta'):
        if record.id in locus_tags:
            SeqIO.write(record, out, 'fasta')

print(f"Wrote {len(locus_tags)} sequences to cds_with_cog.fna")