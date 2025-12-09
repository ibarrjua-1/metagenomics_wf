import os
import pandas as pd
import matplotlib.pyplot as plt

# -----------------------------
# CONFIG — CHANGE THIS
# -----------------------------
BASE_DIR = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies"       # parent folder containing sample dirs
BRACKEN_FILENAME = "bracken.phylum.report"  # file inside each directory
TOP_N = 10                           # number of species to show
# -----------------------------
all_dfs = []

# Loop through each sample directory and load its Bracken report
for sample in sorted(os.listdir(BASE_DIR)):
    sample_path = os.path.join(BASE_DIR, sample)
    bracken_file = os.path.join(sample_path, BRACKEN_FILENAME)

    if os.path.isdir(sample_path) and os.path.exists(bracken_file):
        df = pd.read_csv(bracken_file, sep="\t")
        df["sample"] = sample
        all_dfs.append(df)

if not all_dfs:
    raise ValueError("No Bracken reports found. Check BASE_DIR and BRACKEN_FILENAME.")

df_all = pd.concat(all_dfs, ignore_index=True)

# Keep only species-level rows
df_species = df_all[df_all["taxonomy_lvl"] == "P"]

# Pivot to samples x species (raw counts)
pivot = df_species.pivot_table(
    index="sample",
    columns="name",
    values="new_est_reads",
    fill_value=0
)

# Convert to relative abundance per sample
pivot_rel = pivot.div(pivot.sum(axis=1), axis=0)

# Pick most abundant species across all samples
top_species = pivot_rel.sum().sort_values(ascending=False).head(TOP_N).index

# Stacked bar plot
ax = pivot_rel[top_species].plot(
    kind="bar",
    stacked=True,
    edgecolor="none",
    figsize=(14, 7)
)

ax.set_title(f"Top {TOP_N} Phylum Across All Samples (Bracken)")
ax.set_ylabel("Relative Abundance")
ax.set_xlabel("Sample")
plt.xticks(rotation=90)
plt.legend(bbox_to_anchor=(1.05, 1), loc="upper left")
plt.tight_layout()
plt.show()

# If you want to save instead of just show:
plt.savefig("bracken_top_phylum_stacked_bar.png", dpi=300, bbox_inches="tight")
