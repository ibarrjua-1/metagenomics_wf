#!/bin/bash


# Submit this script with: sbatch <this-filename>
#SBATCH --time=80:00:00   # walltime
#SBATCH --ntasks=50   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 510GB   # memory per CPU core
#SBATCH -J assembly_continue   # job name
#SBATCH --array=0-23                 # Array range (update based on number of FASTA files)

# Notify at the beginning, end of job and on failure.
#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


#!/bin/bash

# Create an array of directories
#!/bin/bash

# Set base paths
INPUT_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/fasta"
OUTPUT_BASE="/resnick/groups/enviromics/sal/Caro_Soil_SIP/"

# Create assemblies folder if it doesn't exist
# Get list of sample bases
FILES=($(ls ${INPUT_DIR}/*combined_R1.fastq.gz | sed 's/_combined_R1.fastq.gz//'))

# Loop over each sample
FILE=${FILES[$SLURM_ARRAY_TASK_ID]}

SAMPLE_NAME=$(basename "$FILE")
R1="${FILE}_combined_R1.fastq.gz"
R2="${FILE}_combined_R2.fastq.gz"
OUTDIR="${OUTPUT_BASE}${SAMPLE_NAME}"

echo "------------------------------------"
echo "Assembling sample: $SAMPLE_NAME"
echo "  R1: $R1"
echo "  R2: $R2"
echo "  Output directory: $OUTDIR"


# Skip if already assembled
if [[ -s "${OUTDIR}/scaffolds.fasta" ]]; then
  echo "Skipping ${SAMPLE_NAME} — ${OUTDIR}/scaffolds.fasta exists"
  exit 0
fi

# Create sample output directory
mkdir -p "$OUTDIR"

# Run metaSPAdes (adjust threads/memory as needed)
/resnick/groups/enviromics/sal/tools/SPAdes-4.2.0-Linux/bin/metaspades.py \
    -1 "$R1" \
    -2 "$R2" \
    -o "$OUTDIR" \
    -t 50 -m 510 -k 21,33,55,77,99,127 \

echo "✅ Finished assembly for $SAMPLE_NAME"

echo "✅ All assemblies complete!"
