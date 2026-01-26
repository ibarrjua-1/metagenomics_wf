#!/bin/bash

# Submit this script with: sbatch <this-filename>
#SBATCH --time=48:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J kallisto_quantify   # job name
#SBATCH --output=/resnick/groups/enviromics/sal/metagenomics_wf/logs/251211_prokka_LS.out
# Notify at the beginning, end of job and on failure.


#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR



READS_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies"

# Create output directory
mkdir -p kallisto_out

# Quantify all 24 samples
echo "Quantifying samples..."

for sample_id in JRP1 JRP2 JRP3 JR71 JR72 JR73 \
                 JSP1 JSP2 JSP3 JS71 JS72 JS73 \
                 LRP1 LRP2 LRP3 LR71 LR72 LR73 \
                 LSP1 LSP2 LSP3 LS71 LS72 LS73; do

    echo "  Processing: ${sample_id}"

    # Find files in the reads directory
    r1=$(ls ${READS_DIR}/Caro-Soil-SIP-pooled__${sample_id}_*_R1.fastq.gz 2>/dev/null)
    r2=$(ls ${READS_DIR}/Caro-Soil-SIP-pooled__${sample_id}_*_R2.fastq.gz 2>/dev/null)

    if [ -z "$r1" ] || [ -z "$r2" ]; then
        echo "    WARNING: Files not found for $sample_id"
        continue
    fi

    kallisto quant \
        -i mag_cds.idx \
        -o kallisto_out/${sample_id} \
        -t 32 \
        $r1 $r2
done

echo ""
echo "✓ Quantification complete"
echo "Total samples processed: $(ls kallisto_out/*/abundance.tsv 2>/dev/null | wc -l)"