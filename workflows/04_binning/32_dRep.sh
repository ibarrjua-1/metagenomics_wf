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
micromamba activate drep

dRep dereplicate -g /resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/all_bins/*.fa -comp 70 -con 10 -p 32 /resnick/groups/enviromics/sal/Caro_Soil_SIP/coassembly/all_bins/dRep 
