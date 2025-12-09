#!/usr/bin/env python3
import os
import pandas as pd
import matplotlib.pyplot as plt

# ---- Explicit CheckV result files (8 samples) ----
file_paths = [
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JRP/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JS/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JSP/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LR/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LRP/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LS/checkv/quality_summary.tsv",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LSP/checkv/quality_summary.tsv",
]

# Map FULL PATH -> sample label (don’t use basename, since it’s the same filename everywhere)
label_map = {
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JR/checkv/quality_summary.tsv":  "JR",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JRP/checkv/quality_summary.tsv": "JRP",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JS/checkv/quality_summary.tsv":  "JS",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/JSP/checkv/quality_summary.tsv": "JSP",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LR/checkv/quality_summary.tsv":  "LR",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LRP/checkv/quality_summary.tsv": "LRP",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LS/checkv/quality_summary.tsv":  "LS",
    "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/LSP/checkv/quality_summary.tsv": "LSP",
}

# ---- Your block, adapted so labels are the sample names ----
dfs = []
for file in file_paths:
    if os.path.exists(file):
        df = pd.read_csv(file, sep="\t")
        df["source_file"] = label_map.get(file, os.path.basename(os.path.dirname(os.path.dirname(file))))
        dfs.append(df)
    elif os.path.exists(file + ".gz"):
        # If gzip-compressed, read that instead
        df = pd.read_csv(file + ".gz", sep="\t", compression="gzip")
        df["source_file"] = label_map.get(file, os.path.basename(os.path.dirname(os.path.dirname(file))))
        dfs.append(df)
    else:
        print(f"Missing: {file}")

if dfs:
    df_all = pd.concat(dfs, ignore_index=True)

    # Write combined table
    out_tsv = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/checkv_summary_all_samples.tsv"
    # Put sample column first for convenience
    if "source_file" in df_all.columns:
        cols = ["source_file"] + [c for c in df_all.columns if c != "source_file"]
        df_all = df_all[cols]
    df_all.to_csv(out_tsv, sep="\t", index=False)
    print(f"Wrote combined TSV → {out_tsv}")

    # Build counts for stacked bar
    if "checkv_quality" not in df_all.columns:
        raise SystemExit("Column 'checkv_quality' not found in CheckV outputs.")

    df_counts = pd.crosstab(df_all["source_file"], df_all["checkv_quality"])
    #quality_order = ["High-quality", "Medium-quality", "Low-quality", "Not-determined"]
    quality_order = ["High-quality", "Medium-quality"]
    for q in quality_order:
        if q not in df_counts.columns:
            df_counts[q] = 0
    df_counts = df_counts[quality_order]  # order columns

    # Plot
    ax = df_counts.plot(kind="bar", stacked=True, figsize=(8, 5), title="CheckV Quality Counts")
    plt.xlabel("Sample")
    plt.ylabel("Count")
    plt.xticks(rotation=45, ha="right")
    plt.tight_layout()

    # Add count labels inside each stacked bar
    for i, row in enumerate(df_counts.values):
        y_offset = 0
        for count in row:
            if count > 0:
                ax.text(i, y_offset + count / 2, str(int(count)), ha='center', va='center', fontsize=8)
                y_offset += count

    out_png = "/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/checkv_quality_stacked_bar_labeled.png"
    plt.savefig(out_png, dpi=300)
    plt.close()
    print(f"Wrote plot → {out_png}")
else:
    print("No valid summary files loaded.")
