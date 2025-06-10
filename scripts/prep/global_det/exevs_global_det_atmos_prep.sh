#!/bin/bash
###############################################################################
# Name of Script: exevs_global_det_atmos_prep.sh
# Developers: Anil Kumar / Anil.Kumar@noaa.gov & Mallory Row / Mallory.Row@noaa.gov
# Purpose of Script: This script is run for the global_det atmos prep step
# Modified for Azure VM compatibility
###############################################################################

set -x

echo

# Load environment (Azure-specific)
if [ -f "${HOME}/spack/share/spack/setup-env.sh" ]; then
    source ${HOME}/spack/share/spack/setup-env.sh
    spack load intel-oneapi-compilers@${intel_ver}
    spack load netcdf-c@${netcdf_ver}
    spack load netcdf-fortran@${netcdf_fortran_ver}
    spack load openmpi@5.0.7
fi

# Run prep work for global deterministic model and observations
python ${USHevs}/global_det/global_det_atmos_prep.py ${SKIP_SOURCES:+--skip "$SKIP_SOURCES"}
export err=$?; err_chk

# Send for missing files (only if SENDMAIL is enabled and files exist)
if [ "${SENDMAIL:-NO}" = "YES" ] ; then
    if ls $DATA/mail_* 1> /dev/null 2>&1; then
        for FILE in $DATA/mail_*; do
            $FILE
        done
    fi
fi
