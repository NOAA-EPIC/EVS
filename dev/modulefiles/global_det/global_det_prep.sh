#!/bin/bash
# modulefile for EVS global_det component, prep step

set -x

### 1. INITIALIZATION ###
export HPC_OPT="/opt/libs"
export LOG_FILE="/tmp/global_det_prep_$(date +%Y%m%d).log"
exec > >(tee -a ${LOG_FILE}) 2>&1
echo "EVS global_det prep step - $(date)"
    
### 2. LOAD COMPILER ###
if [ -f "$HOME/spack/share/spack/setup-env.sh" ]; then
    source "$HOME/spack/share/spack/setup-env.sh"
    spack load intel-oneapi-compilers@${intel_ver}
    echo "Loaded Intel compiler via Spack"
elif [ -f "/opt/intel/oneapi/compiler/${intel_ver}/env/vars.sh" ]; then
    source "/opt/intel/oneapi/compiler/${intel_ver}/env/vars.sh"
    echo "Loaded Intel compiler from OneAPI installation"
else
    echo "ERROR: Intel compiler not found"
    exit 1
fi

### 3. LOAD COMPONENTS ###
# Load Spack-managed packages
spack load gsl@${gsl_ver}
spack load netcdf-c@${netcdf_ver}
spack load netcdf-fortran@${netcdf_fortran_ver}
spack load openmpi@5.0.7               # Replaces cray-pals
spack load prod-util@${prod_util_ver}
spack load jasper@${jasper_ver}
spack load grib-util@${grib_util_ver}
spack load cdo@${cdo_ver}
spack load nco@${nco_ver}

# System libraries
export LD_LIBRARY_PATH="/usr/lib/x86_64-linux-gnu:$LD_LIBRARY_PATH"  # For libjpeg, libpng, etc.

# Special cases
export PATH="/home/anilk/grib2:$PATH"           # wgrib2
export PATH="/home/anilk/bufrlib/bin:$PATH"     # BUFRLIB
export PATH="/home/anilk/met/${met_ver}/bin:$PATH"       # MET
export PATH="/home/anilk/METplus/bin:$PATH"     # METplus

### 4. VERIFICATION ###
echo -e "\n=== LOADED COMPONENTS ==="
{
    echo "Compiler: $(ifx --version | head -1)"
    echo "GSL: $(gsl-config --version)"
    echo "NetCDF: $(nc-config --version)"
    echo "NetCDF-Fortran: $(nf-config --version || echo 'Not found')"
    echo "MPI: $(mpirun --version | head -1)"
    echo "prod_util: $(which prod_util_executable || echo 'Not found')"  # Replace with actual command
    echo "wgrib2: $(wgrib2 -config 2>&1 | head -1)"
    echo "MET: $(met_version 2>&1 | head -1)"
    echo "METplus: $(run_metplus.py --version 2>&1 | head -1 || echo 'Not found')"
} | tee -a $LOG_FILE

echo -e "\n=== FINAL ENVIRONMENT ==="
echo "PATH: $PATH" | tee -a $LOG_FILE
echo "LD_LIBRARY_PATH: $LD_LIBRARY_PATH" | tee -a $LOG_FILE

set +x

### 5. RUN PREP STEP ###
# Add your actual prep step commands here
# Example:
# prep_script.sh --config global_det_prep.conf

echo "Prep step completed at $(date)" | tee -a $LOG_FILE
