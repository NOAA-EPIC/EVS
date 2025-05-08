#PBS -N jevs_global_det_atmos_prep_00
#PBS -j oe
#PBS -S /bin/bash
#PBS -q dev
#PBS -A VERF-DEV
#PBS -l walltime=00:45:00
#PBS -l place=exclhost,select=1:ncpus=1:mem=100GB
#PBS -l debug=true

set -x 

cd $PBS_O_WORKDIR

export model=evs
export HOMEevs=/gpfs/f6/bil-fire8/scratch/$USER/EVS

export SENDCOM=YES
export SENDMAIL=NO
export KEEPDATA=YES
export job=${PBS_JOBNAME:-jevs_global_det_atmos_prep}
export jobid=$job.${PBS_JOBID:-$$}
export SITE=$(cat /etc/cluster_name)
export vhr=00

source $HOMEevs/versions/run.ver
module reset
module load prod_envir/${prod_envir_ver}
source $HOMEevs/dev/modulefiles/global_det/global_det_prep.sh

evs_ver_2d=$(echo $evs_ver | cut -d'.' -f1-2)

export MAILTO='anil.kumar@noaa.gov'

export envir=prod
export NET=evs
export STEP=prep
export COMPONENT=global_det
export RUN=atmos

export DATAROOT=/gpfs/f6/bil-fire8/scratch/Anil.Kumar/stmp2/$USER/evs_test/$envir/tmp
export TMPDIR=$DATAROOT
export COMIN=/gpfs/f6/bil-fire8/scratch/Anil.Kumar/stmp2/$USER/$NET/$evs_ver_2d
export COMOUT=/gpfs/f6/bil-fire8/scratch/Anil.Kumar/stmp2/$USER/$NET/$evs_ver_2d/$STEP/$COMPONENT/$RUN

export MODELNAME="gfs"
export OBSNAME="prepbufr_gdas"
#export MODELNAME="cfs cmc cmc_regional dwd fnmoc gfs imd jma metfra ukmet ecmwf"
#export OBSNAME="osi_saf ghrsst_ospo ccpa_accum24hr prepbufr_gdas prepbufr_nam"

# CALL executable job script here
$HOMEevs/jobs/JEVS_GLOBAL_DET_PREP

######################################################################
# Purpose: This does the prep work for the global deterministic atmospheric
######################################################################
