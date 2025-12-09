# save as pivot_checkv_quality.py and run: python pivot_checkv_quality.py
import pandas as pd

combined = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/checkv_all_samples.tsv"
out_counts = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/checkv_quality_counts.tsv"

df = pd.read_csv(combined, sep="\t")

# Ensure columns exist
assert "Sample" in df.columns, "Missing 'Sample' column"
assert "checkv_quality" in df.columns, "Missing 'checkv_quality' column"

# Clean NA
df["checkv_quality"] = df["checkv_quality"].fillna("NA")

# Per-sample by-category counts (wide)
counts = (
    df.groupby(["Sample", "checkv_quality"])
      .size()
      .unstack(fill_value=0)
      .reset_index()
      .sort_values("Sample")
)

counts.to_csv(out_counts, sep="\t", index=False)
print(f"Wrote: {out_counts}")
