import pandas as pd
import numpy as np
from scipy import stats
from statsmodels.stats.multitest import multipletests
import matplotlib.pyplot as plt
import matplotlib
matplotlib.use('Agg')

print("="*70)
print("FINAL WORKING ANALYSIS - HANDLING NaN P-VALUES")
print("="*70)

# Load data
abundance_df = pd.read_csv("MAG_relative_abundance_from_mean.tsv", sep='\t', index_col=0)

JR_samples = ['JR71_7', 'JR72_8', 'JR73_9']
JS_samples = ['JS71_10', 'JS72_11', 'JS73_12']

print(f"\n[1] Processing {len(abundance_df)} MAGs...")

# Calculate statistics
results = []
for i, mag in enumerate(abundance_df.index, 1):
    if i % 20 == 0:
        print(f"    MAG {i}/{len(abundance_df)}...")
    
    JR_values = abundance_df.loc[mag, JR_samples].values
    JS_values = abundance_df.loc[mag, JS_samples].values
    
    jr_mean = JR_values.mean()
    js_mean = JS_values.mean()
    t_stat, p_val = stats.ttest_ind(JR_values, JS_values)
    
    pseudocount = 1e-10
    fc = (js_mean + pseudocount) / (jr_mean + pseudocount)
    
    results.append({
        'MAG': mag,
        'JR_mean': jr_mean,
        'JS_mean': js_mean,
        'fold_change': fc,
        'log2_fc': np.log2(fc),
        'p_value': p_val,
        't_statistic': t_stat
    })

# Create DataFrame
results_df = pd.DataFrame(results)
print(f"✓ Created DataFrame with {len(results_df)} MAGs")

# FDR correction - HANDLE NaN VALUES
print(f"\n[2] FDR correction...")

p_vals = results_df['p_value'].values
valid_mask = np.isfinite(p_vals)

print(f"    Total p-values: {len(p_vals)}")
print(f"    Valid p-values: {valid_mask.sum()}")
print(f"    NaN p-values: {(~valid_mask).sum()}")

if (~valid_mask).any():
    print(f"    MAGs with NaN p-values (absent in both groups):")
    nan_mags = results_df.loc[~valid_mask, 'MAG'].tolist()
    for mag in nan_mags:
        print(f"      - {mag}")

# Apply FDR correction ONLY to valid p-values
p_adjusted_full = np.full(len(p_vals), np.nan)  # Initialize with NaN
reject_full = np.full(len(p_vals), False)  # Initialize with False

if valid_mask.sum() > 0:
    valid_pvals = p_vals[valid_mask]
    reject_valid, p_adjusted_valid, _, _ = multipletests(valid_pvals, alpha=0.05, method='fdr_bh')
    
    # Put corrected values back in the right positions
    p_adjusted_full[valid_mask] = p_adjusted_valid
    reject_full[valid_mask] = reject_valid
    
    print(f"    Significant MAGs: {reject_valid.sum()}/{valid_mask.sum()}")

# Assign to DataFrame
results_df['p_adjusted'] = p_adjusted_full
results_df['significant'] = reject_full

print(f"✓ p_adjusted assigned: {results_df['p_adjusted'].notna().sum()}/{len(results_df)}")

# Verify
print(f"\n[3] Verification (first 10):")
print(results_df[['MAG', 'p_value', 'p_adjusted', 'significant']].head(10))

# Save
output_file = 'JR_vs_JS_FINAL.tsv'
results_df.to_csv(output_file, sep='\t', index=False, float_format='%.6e')
print(f"\n✓ Saved: {output_file}")

# CREATE VOLCANO PLOT
print(f"\n[4] Creating volcano plot...")

# Use only valid p-values for plotting
plot_df = results_df[results_df['p_adjusted'].notna()].copy()

x = plot_df['log2_fc'].clip(-10, 10).values
y = -np.log10(plot_df['p_adjusted'].clip(lower=1e-300).values)

valid = np.isfinite(x) & np.isfinite(y)
print(f"    Plotting {valid.sum()}/{len(results_df)} MAGs (excluded {(~valid_mask).sum()} with NaN p-values)")

if valid.sum() > 0:
    fig, ax = plt.subplots(figsize=(12, 8))
    
    # Separate by significance
    sig = plot_df['significant'].values
    
    # Non-significant (gray)
    ax.scatter(
        x[~sig & valid],
        y[~sig & valid],
        c='lightgray',
        s=25,
        alpha=0.5,
        edgecolors='none',
        label=f'Not significant (n={(~sig & valid).sum()})'
    )
    
    # Significant (red)
    ax.scatter(
        x[sig & valid],
        y[sig & valid],
        c='red',
        s=60,
        alpha=0.7,
        edgecolors='darkred',
        linewidths=0.8,
        label=f'Significant FDR<0.05 (n={(sig & valid).sum()})'
    )
    
    # Annotate top 5 most significant
    top5 = plot_df.nsmallest(5, 'p_adjusted')
    for _, row in top5.iterrows():
        idx = plot_df.index.get_loc(row.name)
        if valid[idx]:
            ax.annotate(
                row['MAG'].replace('bin.', ''),
                xy=(x[idx], y[idx]),
                xytext=(5, 5),
                textcoords='offset points',
                fontsize=8,
                bbox=dict(boxstyle='round,pad=0.3', facecolor='yellow', alpha=0.5)
            )
    
    # Threshold lines
    ax.axhline(-np.log10(0.05), color='blue', linestyle='--', 
               linewidth=2, alpha=0.7, label='FDR = 0.05')
    ax.axvline(-1, color='green', linestyle='--', linewidth=1.5, alpha=0.5)
    ax.axvline(1, color='green', linestyle='--', linewidth=1.5, alpha=0.5, 
               label='2-fold change')
    ax.axvline(0, color='gray', linestyle='-', linewidth=1, alpha=0.3)
    
    # Labels & formatting
    ax.set_xlabel('Log2 Fold Change (JS / JR)', fontsize=13, fontweight='bold')
    ax.set_ylabel('-Log10(Adjusted P-value)', fontsize=13, fontweight='bold')
    ax.set_title(f'Volcano Plot: JR vs JS\n{sig.sum()} significant MAGs (FDR < 0.05)', 
                 fontsize=15, fontweight='bold', pad=20)
    ax.legend(loc='upper right', frameon=True, fontsize=10)
    ax.grid(True, alpha=0.3, linestyle=':')
    
    ax.set_xlim(-6, 6)
    ax.set_ylim(0, max(y[valid]) * 1.1)
    
    plt.tight_layout()
    plt.savefig('volcano_FINAL.png', dpi=300, bbox_inches='tight')
    print(f"✓ Saved: volcano_FINAL.png")
    
    import os
    print(f"    File size: {os.path.getsize('volcano_FINAL.png'):,} bytes")

# Summary statistics
print(f"\n[5] Summary:")
print(f"    Total MAGs analyzed: {len(results_df)}")
print(f"    MAGs with valid p-values: {results_df['p_adjusted'].notna().sum()}")
print(f"    MAGs excluded (absent in both groups): {results_df['p_adjusted'].isna().sum()}")
print(f"    Significant MAGs (FDR < 0.05): {results_df['significant'].sum()}")

sig_results = results_df[results_df['significant']].copy()
if len(sig_results) > 0:
    jr_higher = (sig_results['log2_fc'] < 0).sum()
    js_higher = (sig_results['log2_fc'] > 0).sum()
    
    print(f"    Higher in JR: {jr_higher}")
    print(f"    Higher in JS: {js_higher}")
    
    # Top 10
    print(f"\n[6] Top 10 most significant MAGs:")
    top10 = sig_results.nsmallest(10, 'p_adjusted')
    for _, row in top10.iterrows():
        direction = "JR" if row['log2_fc'] < 0 else "JS"
        fc = 2**abs(row['log2_fc'])
        print(f"    {row['MAG']:20s} {fc:5.2f}× → {direction}  "
              f"(JR:{row['JR_mean']:.4f}, JS:{row['JS_mean']:.4f}, p={row['p_adjusted']:.2e})")

plt.close()

print("\n" + "="*70)
print("✓✓✓ SUCCESS! VOLCANO PLOT CREATED! ✓✓✓")
print("="*70)
print(f"\nFiles created:")
print(f"  1. {output_file}")
print(f"  2. volcano_FINAL.png")
print("="*70)