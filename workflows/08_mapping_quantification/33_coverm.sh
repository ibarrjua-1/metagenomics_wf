#!/bin/bash

# Submit this sciript with: sbatch <this-filename>
#SBATCH --time=24:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 190GB   # memory per CPU core
#SBATCH -J dRep   # job name
# Notify at the beginning, end of job and on failure.


#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


eval "$(micromamba shell hook --shell bash)"
micromamba activate coverm
#!/bin/bash
SCRATCH=/resnick/scratch/jibarraa/coverm_test
mkdir -p "$SCRATCH"
export TMPDIR="$SCRATCH"
GENOMES_DIR="/resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/all_bins/dRep/dereplicated_genomes/"

# one line per sample: sample_ID<TAB>R1<TAB>R2
SAMPLES_FILE="fastq_single_list.txt"
FASTQ_PATH="/resnick/groups/enviromics/sal/Caro_Soil_SIP/single_assemblies/"

coverm genome \
    --genome-fasta-directory "$GENOMES_DIR" \
    -x fa \
    --methods mean relative_abundance \
    --coupled $(awk -v P="$FASTQ_PATH" '{print P"/"$1" "P"/"$2}' "$SAMPLES_FILE") \
    --threads 32 \
    --output-file /resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/all_bins/dRep/coverm_genome_abundance.tsv
