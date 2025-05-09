#!/bin/bash
##SBATCH --job-name=evs_global_det_atmos_prep
##SBATCH --output evs_global_det_atmos_prep.txt
##SBATCH --error=output
##SBATCH --qos=normal
##SBATCH --account=bil-fire8
##SBATCH -t 00:10:00
##SBATCH --nodes=1
##SBATCH --tasks-per-node=1
##SBATCH --cpus-per-task=1
##SBATCH --verbose
##SBATCH --partition=batch
##SBATCH --exclusive --clusters=c6

##PBS -N jevs_global_det_atmos_prep_00
##PBS -j oe
##PBS -S /bin/bash
##PBS -q dev
##PBS -A VERF-DEV
##PBS -l walltime=00:45:00
##PBS -l place=exclhost,select=1:ncpus=1:mem=100GB
##PBS -l debug=true

set -x 

cd $PBS_O_WORKDIR

export model=evs
#export HOMEevs=/lfs/h2/emc/vpppg/noscrub/$USER/EVS
export HOMEevs=/gpfs/f6/bil-fire8/scratch/David.Burrows/evs/apr28/EVS

export SENDCOM=YES
export SENDMAIL=NO
export KEEPDATA=YES
#export job=${PBS_JOBNAME:-jevs_global_det_atmos_prep}
#export jobid=$job.${PBS_JOBID:-$$}
export job=${SLURM_JOB_NAME:-jevs_global_det_atmos_prep}
export jobid=$job.${SLURM_JOB_ID:-$$}
export SITE=$(cat /etc/cluster_name)
export vhr=00

source $HOMEevs/versions/run.ver
module reset
module load prod_envir/${prod_envir_ver}
source $HOMEevs/dev/modulefiles/global_det/global_det_prep.sh
export METPLUS_PATH=${metplus_ROOT}
export MET_ROOT=${met_ROOT}

evs_ver_2d=$(echo $evs_ver | cut -d'.' -f1-2)

export MAILTO='david.burrows@noaa.gov'

export envir=prod
export NET=evs
export STEP=prep
export COMPONENT=global_det
export RUN=atmos

#export DATAROOT=/lfs/h2/emc/stmp/$USER/evs_test/$envir/tmp
#export TMPDIR=$DATAROOT
#export COMIN=/lfs/h2/emc/vpppg/noscrub/$USER/$NET/$evs_ver_2d
#export COMOUT=/lfs/h2/emc/vpppg/noscrub/$USER/$NET/$evs_ver_2d/$STEP/$COMPONENT/$RUN

export COMIN=/gpfs/f6/bil-fire8/scratch/David.Burrows/evs/comin/$NET/$evs_ver_2d
export COMOUT=/gpfs/f6/bil-fire8/scratch/David.Burrows/evs/comout/$NET/$evs_ver_2d/$STEP/$COMPONENT/$RUN
export DATAROOT=/gpfs/f6/bil-fire8/scratch/David.Burrows/evs/stmp
export COMROOT=/gpfs/f6/bil-fire8/scratch/David.Burrows/evs/comroot
export TMPDIR=${DATAROOT}
export PDY=20230221
export CDATE=${PDY}${vhr}

export MODELNAME="gfs"
export OBSNAME="prepbufr_gdas"

# CALL executable job script here
$HOMEevs/jobs/JEVS_GLOBAL_DET_PREP

######################################################################
# Purpose: This does the prep work for the global deterministic atmospheric
######################################################################
