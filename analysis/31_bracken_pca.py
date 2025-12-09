import os
import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt
from adjustText import adjust_text

# -----------------------------
# CONFIG – CHANGE THIS TO MATCH YOUR SETUP
# -----------------------------
BASE_DIR = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies"
BRACKEN_FILENAME = "bracken.phylum.report"
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

# -------------------------
# FILTER TO PHYLUM LEVEL
# -------------------------
df_phylum = df_all[df_all["taxonomy_lvl"] == "P"]

# -------------------------
# CREATE PIVOT TABLE
# Pivot to samples (rows) x phyla (columns) with raw counts
# -------------------------
pivot = df_phylum.pivot_table(
    index="sample",
    columns="name",
    values="new_est_reads",
    fill_value=0
)

# -------------------------
# CONVERT TO RELATIVE ABUNDANCE
# -------------------------
pivot_rel = pivot.div(pivot.sum(axis=1), axis=0)

# -------------------------
# REMOVE PHYLA WITH ALL ZEROS (good practice)
# -------------------------
pivot_rel = pivot_rel.loc[:, (pivot_rel != 0).any(axis=0)]

# -------------------------
# STANDARDIZE (important for PCA)
# -------------------------
scaler = StandardScaler()
X_scaled = scaler.fit_transform(pivot_rel)

# -------------------------
# RUN PCA
# -------------------------
pca = PCA(n_components=2)
pcs = pca.fit_transform(X_scaled)

# Put into a dataframe for plotting
df_pca = pd.DataFrame({
    "PC1": pcs[:, 0],
    "PC2": pcs[:, 1],
}, index=pivot_rel.index)

# -------------------------
# PLOT PCA
# -------------------------
plt.figure(figsize=(10, 8))
plt.scatter(df_pca["PC1"], df_pca["PC2"], s=100, alpha=0.7)

# Add sample labels with automatic adjustment
texts = []
for sample in df_pca.index:
    texts.append(
        plt.text(
            df_pca.loc[sample, "PC1"],
            df_pca.loc[sample, "PC2"],
            sample,
            fontsize=9
        )
    )

adjust_text(texts, arrowprops=dict(arrowstyle="-", lw=0.5))

plt.xlabel(f"PC1 ({pca.explained_variance_ratio_[0]*100:.2f}% variance)")
plt.ylabel(f"PC2 ({pca.explained_variance_ratio_[1]*100:.2f}% variance)")
plt.title("PCA of Phylum-Level Relative Abundance (Bracken)")
plt.grid(alpha=0.3)
plt.tight_layout()

# Save figure
plt.savefig("bracken_phylum_PCA.png", dpi=300, bbox_inches="tight")
plt.show()

# -------------------------
# OPTIONAL: Print explained variance
# -------------------------
print(f"\nExplained variance:")
print(f"PC1: {pca.explained_variance_ratio_[0]*100:.2f}%")
print(f"PC2: {pca.explained_variance_ratio_[1]*100:.2f}%")
print(f"Total: {sum(pca.explained_variance_ratio_)*100:.2f}%")

# -------------------------
# OPTIONAL: Show top contributing phyla to each PC
# -------------------------
print("\nTop 5 phyla contributing to PC1:")
loadings_pc1 = pd.Series(pca.components_[0], index=pivot_rel.columns)
print(loadings_pc1.abs().sort_values(ascending=False).head(5))

print("\nTop 5 phyla contributing to PC2:")
loadings_pc2 = pd.Series(pca.components_[1], index=pivot_rel.columns)
print(loadings_pc2.abs().sort_values(ascending=False).head(5))
