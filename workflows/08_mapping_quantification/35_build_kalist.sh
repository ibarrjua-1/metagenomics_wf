#!/bin/bash
# Submit this script with: sbatch build_kallisto_indices.sh
#SBATCH --time=2:00:00               # indices build fast
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --nodes=1
#SBATCH --mem=32GB
#SBATCH -J "kallisto_index"
#SBATCH --mail-user=jibarraa@caltech.edu
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL
#SBATCH -o logs/kallisto_index.out
#SBATCH -e logs/kallisto_index.err

set -e

# Create log directory
mkdir -p logs

# ============================================================================
# Configuration
# ============================================================================
BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP"
FUNC_DIR="${BASE}/functional_analysis"
COASSEMBLY_DIR="${BASE}/coassembly"

KALLISTO="kallisto"
THREADS=32

# Create output directory
mkdir -p "${FUNC_DIR}"

echo "========================================================================"
echo "Building kallisto indices for all 8 co-assemblies"
echo "Date: $(date)"
echo "========================================================================"
echo ""

# ============================================================================
# Build indices
# ============================================================================
for COASSEMBLY in JR JRP JS JSP LR LRP LS LSP; do
    echo "Building index for ${COASSEMBLY}..."
    
    GENES="${COASSEMBLY_DIR}/${COASSEMBLY}/megahit/1000_prokka/PROKKA_*.ffn"
    INDEX="${FUNC_DIR}/${COASSEMBLY}_genes.idx"
    
    # Find the actual gene file
    GENES_FILE=$(ls ${COASSEMBLY_DIR}/${COASSEMBLY}/megahit/1000_prokka/PROKKA_*.ffn 2>/dev/null | head -1)
    
    if [ -z "$GENES_FILE" ] || [ ! -f "$GENES_FILE" ]; then
        echo "  ERROR: Gene file not found for ${COASSEMBLY}"
        echo "  Looked in: ${COASSEMBLY_DIR}/${COASSEMBLY}/megahit/1000_prokka/"
        continue
    fi
    
    echo "  Gene file: ${GENES_FILE}"
    
    if [ ! -f "$INDEX" ]; then
        $KALLISTO index -t $THREADS -i "$INDEX" "$GENES_FILE"
        echo "  ✓ Created: ${INDEX}"
    else
        echo "  ✓ Already exists: ${INDEX}"
    fi
    
    echo ""
done

echo "========================================================================"
echo "All indices built!"
echo "Date: $(date)"
echo "========================================================================"
