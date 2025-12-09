#!/bin/bash
# Submit this script with: sbatch run_kallisto_array.sh
#SBATCH --time=02:00:00              # walltime (kallisto is fast)
#SBATCH --ntasks=1                   # one task per sample
#SBATCH --cpus-per-task=32           # threads for kallisto
#SBATCH --nodes=1                    # number of nodes
#SBATCH --mem=180GB                   # memory per job
#SBATCH -J "kallisto"                # job name
#SBATCH --array=0-23                 # 24 samples (0-23)
#SBATCH --mail-user=jibarraa@caltech.edu
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH -o logs/kallisto_%A_%a.out   # STDOUT with array ID
#SBATCH -e logs/kallisto_%A_%a.err   # STDERR with array ID

# ============================================================================
# Kallisto quantification - SLURM array version
# ============================================================================

set -e

# Create log directory
mkdir -p logs
eval "$(micromamba shell hook --shell bash)"
micromamba activate kallisto
# ============================================================================
# Configuration
# ============================================================================
BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"
FUNC_DIR="${BASE}/functional_analysis"
READS_DIR="${BASE}/single_assemblies"
COASSEMBLY_DIR="${BASE}/coassembly"

KALLISTO="kallisto"  # or /path/to/kallisto if needed
THREADS=32

# ============================================================================
# Define all 24 samples in order
# ============================================================================
SAMPLES=(
    # JR co-assembly (0-2)
    "JR71_7"
    "JR72_8"
    "JR73_9"
    
    # JRP co-assembly (3-5)
    "JRP1_1"
    "JRP2_2"
    "JRP3_3"
    
    # JS co-assembly (6-8)
    "JS71_10"
    "JS72_11"
    "JS73_12"
    
    # JSP co-assembly (9-11)
    "JSP1_4"
    "JSP2_5"
    "JSP3_6"
    
    # LR co-assembly (12-14)
    "LR71_19"
    "LR72_20"
    "LR73_21"
    
    # LRP co-assembly (15-17)
    "LRP1_13"
    "LRP2_14"
    "LRP3_15"
    
    # LS co-assembly (18-20)
    "LS71_22"
    "LS72_23"
    "LS73_24"
    
    # LSP co-assembly (21-23)
    "LSP1_16"
    "LSP2_17"
    "LSP3_18"
)

# Map sample to co-assembly
declare -A SAMPLE_TO_COASSEMBLY=(
    ["JR71_7"]="JR"   ["JR72_8"]="JR"   ["JR73_9"]="JR"
    ["JRP1_1"]="JRP"  ["JRP2_2"]="JRP"  ["JRP3_3"]="JRP"
    ["JS71_10"]="JS"  ["JS72_11"]="JS"  ["JS73_12"]="JS"
    ["JSP1_4"]="JSP"  ["JSP2_5"]="JSP"  ["JSP3_6"]="JSP"
    ["LR71_19"]="LR"  ["LR72_20"]="LR"  ["LR73_21"]="LR"
    ["LRP1_13"]="LRP" ["LRP2_14"]="LRP" ["LRP3_15"]="LRP"
    ["LS71_22"]="LS"  ["LS72_23"]="LS"  ["LS73_24"]="LS"
    ["LSP1_16"]="LSP" ["LSP2_17"]="LSP" ["LSP3_18"]="LSP"
)

# ============================================================================
# Get sample for this array task
# ============================================================================
SAMPLE="${SAMPLES[$SLURM_ARRAY_TASK_ID]}"
COASSEMBLY="${SAMPLE_TO_COASSEMBLY[$SAMPLE]}"

echo "========================================================================"
echo "SLURM Array Task ID: ${SLURM_ARRAY_TASK_ID}"
echo "Sample: ${SAMPLE}"
echo "Co-assembly: ${COASSEMBLY}"
echo "Date: $(date)"
echo "========================================================================"
echo ""

# ============================================================================
# Define paths
# ============================================================================
R1="${READS_DIR}/${SAMPLE}/${SAMPLE}-R1.fastq.gz"
R2="${READS_DIR}/${SAMPLE}/${SAMPLE}-R2.fastq.gz"
INDEX="${FUNC_DIR}/${COASSEMBLY}_genes.idx"
OUTDIR="${FUNC_DIR}/${SAMPLE}"

echo "Reads R1: ${R1}"
echo "Reads R2: ${R2}"
echo "Index:    ${INDEX}"
echo "Output:   ${OUTDIR}"
echo ""

# ============================================================================
# Check files exist
# ============================================================================
if [ ! -f "$R1" ]; then
    echo "ERROR: R1 file not found: ${R1}"
    exit 1
fi

if [ ! -f "$R2" ]; then
    echo "ERROR: R2 file not found: ${R2}"
    exit 1
fi

if [ ! -f "$INDEX" ]; then
    echo "ERROR: Index not found: ${INDEX}"
    echo "Please run build_kallisto_indices.sh first!"
    exit 1
fi

# ============================================================================
# Run kallisto quant
# ============================================================================
echo "Running kallisto quant..."
echo "Command:"
echo "$KALLISTO quant -i ${INDEX} -o ${OUTDIR} -t ${THREADS} ${R1} ${R2}"
echo ""

$KALLISTO quant \
    -i "$INDEX" \
    -o "$OUTDIR" \
    -t $THREADS \
    "$R1" "$R2"

# ============================================================================
# Check output
# ============================================================================
if [ -f "${OUTDIR}/abundance.tsv" ]; then
    echo ""
    echo "========================================================================"
    echo "SUCCESS!"
    echo "========================================================================"
    echo "Output files:"
    ls -lh "${OUTDIR}/"
    echo ""
    echo "First few lines of abundance.tsv:"
    head -5 "${OUTDIR}/abundance.tsv"
    echo ""
    
    # Extract mapping stats from run_info.json
    if [ -f "${OUTDIR}/run_info.json" ]; then
        echo "Mapping statistics:"
        grep -E "n_processed|n_pseudoaligned|p_pseudoaligned" "${OUTDIR}/run_info.json" || true
    fi
else
    echo ""
    echo "========================================================================"
    echo "ERROR: Output file not created!"
    echo "========================================================================"
    exit 1
fi

echo ""
echo "Done: $(date)"
