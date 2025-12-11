#!/bin/bash

# Submit this sciript with: sbatch <this-filename>
#SBATCH --time=32:00:00   # walltime
#SBATCH --ntasks=32   # number of processor cores (i.e. tasks)
#SBATCH --nodes=1   # number of nodes
#SBATCH --mem 1500GB   # memory per CPU core
#SBATCH -J bracken2byiuld   # job name
#SBATCH --output=/resnick/groups/enviromics/sal/metagenomics_wf/logs/bracken_build.out

# Notify at the beginning, end of job and on failure.


#SBATCH --mail-user=jibarraa@caltech.edu   # email address
#SBATCH --mail-type=BEGIN
#SBATCH --mail-type=END
#SBATCH --mail-type=FAIL

## /SBATCH -p general # partition (queue)
## /SBATCH -o slurm.assembly.%N.%j.out # STDOUT
## /SBATCH -e slurm.assembly.%N.%j.err # STDERR


eval "$(micromamba shell hook --shell bash)"
micromamba activate kraken2

/resnick/groups/enviromics/sal/tools/Bracken/bracken-build -d /resnick/groups/enviromics/databases/KRAKEN2_DB -t 32 -l 150 -x /resnick/groups/enviromics/sal/tools/kraken2/
