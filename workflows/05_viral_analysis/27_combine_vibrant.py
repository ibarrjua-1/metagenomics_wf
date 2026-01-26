import pandas as pd
import glob
import os

# -------------------------
# CONFIG
# -------------------------
BASE_DIR = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly"
OUTPUT_FILE = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/vibrant_amgs_combined.tsv"

# Pattern to match the files
FILE_PATTERN = os.path.join(BASE_DIR, "*/vibrant/VIBRANT_final.contigs/VIBRANT_results_final.contigs/VIBRANT_AMG_pathways_final.contigs.tsv")

print("=" * 70)
print("COMBINING VIBRANT AMG PATHWAY FILES")
print("=" * 70)

# -------------------------
# Find all matching files
# -------------------------
print(f"\nSearching for files matching pattern:")
print(f"{FILE_PATTERN}")

files = glob.glob(FILE_PATTERN)

if not files:
    print(f"\n❌ ERROR: No files found matching pattern!")
    print(f"Check if the path exists and files are present")
    exit(1)

print(f"\n✓ Found {len(files)} files:")
for f in files:
    print(f"  - {f}")

# -------------------------
# Combine files
# -------------------------
print(f"\nCombining files...")

all_data = []

for file_path in files:
    # Extract sample name from path (the * value)
    # Path structure: .../coassembly/SAMPLE_NAME/vibrant/...
    sample_name = file_path.split('/coassembly/')[1].split('/vibrant')[0]

    print(f"\n  Processing {sample_name}...")

    # Read the file
    try:
        df = pd.read_csv(file_path, sep='\t')

        # Add sample column
        df['sample'] = sample_name

        print(f"    ✓ Loaded {len(df)} rows")

        all_data.append(df)

    except Exception as e:
        print(f"    ❌ Error reading file: {e}")
        continue

# -------------------------
# Concatenate all dataframes
# -------------------------
if not all_data:
    print("\n❌ ERROR: No data was loaded successfully!")
    exit(1)

print(f"\nConcatenating all dataframes...")
combined_df = pd.concat(all_data, ignore_index=True)

print(f"✓ Combined dataframe has {len(combined_df)} total rows")
print(f"✓ Samples included: {combined_df['sample'].unique().tolist()}")

# -------------------------
# Save combined file
# -------------------------
print(f"\nSaving to: {OUTPUT_FILE}")

# Create output directory if it doesn't exist
os.makedirs(os.path.dirname(OUTPUT_FILE), exist_ok=True)

combined_df.to_csv(OUTPUT_FILE, sep='\t', index=False)

print(f"✓ Saved successfully!")

# -------------------------
# Summary statistics
# -------------------------
print("\n" + "=" * 70)
print("SUMMARY")
print("=" * 70)
print(f"Total files combined: {len(files)}")
print(f"Total rows: {len(combined_df)}")
print(f"Columns: {list(combined_df.columns)}")
print(f"\nRows per sample:")
print(combined_df['sample'].value_counts().sort_index())
print("=" * 70)
