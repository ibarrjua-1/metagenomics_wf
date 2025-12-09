import pandas as pd
from sklearn.decomposition import PCA
from sklearn.preprocessing import StandardScaler
import matplotlib.pyplot as plt

# -------------------------
# LOAD RELATIVE ABUNDANCE
# -------------------------
df = pd.read_csv("MAG_relative_abundance_from_mean.tsv", sep="\t")

# Rows = MAGs, Columns = samples
# For PCA on samples, we need samples as rows
df_samples = df.set_index("Genome").T

# -------------------------
# OPTIONAL: Remove columns that have all zeros
# (rare for relative abundance, but good practice)
# -------------------------
df_samples = df_samples.loc[:, (df_samples != 0).any(axis=0)]

# -------------------------
# STANDARDIZE (important)
# PCA works best on scaled data
# -------------------------
scaler = StandardScaler()
X_scaled = scaler.fit_transform(df_samples)

# -------------------------
# RUN PCA
# -------------------------
pca = PCA(n_components=2)
pcs = pca.fit_transform(X_scaled)

# Put into a dataframe for plotting
df_pca = pd.DataFrame({
    "PC1": pcs[:, 0],
    "PC2": pcs[:, 1],
}, index=df_samples.index)

# -------------------------
# PLOT PCA
# -------------------------
from adjustText import adjust_text
import matplotlib.pyplot as plt

plt.figure(figsize=(8, 6))
plt.scatter(df_pca["PC1"], df_pca["PC2"])

texts = []
for sample in df_pca.index:
    texts.append(
        plt.text(
            df_pca.loc[sample, "PC1"],
            df_pca.loc[sample, "PC2"],
            sample,
            fontsize=8
        )
    )

adjust_text(texts, arrowprops=dict(arrowstyle="-", lw=0.5))

plt.xlabel(f"PC1 ({pca.explained_variance_ratio_[0]*100:.2f}% variance)")
plt.ylabel(f"PC2 ({pca.explained_variance_ratio_[1]*100:.2f}% variance)")
plt.title("PCA of MAG Relative Abundance (Auto Adjusted Labels)")
plt.tight_layout()
plt.show()
plt.savefig("MAG_PCA.png", dpi=300, bbox_inches="tight")
