#!/bin/bash
set -eux

# Location of PWD and package source directory
readonly pkg_root=$(cd "$(dirname "$(readlink -f -n "${BASH_SOURCE[0]}" )" )/.." && pwd -P)

# User options
BUILD_DEBUG=${BUILD_DEBUG:-NO}
BUILD_CLEAN=${BUILD_CLEAN:-YES}
BUILD_VERBOSE=${BUILD_VERBOSE:-YES}
export EXECevs=${EXECevs:-${pkg_root}/exec}

# Load version tags
source ${pkg_root}/versions/build.ver

# Load Spack environment
if [ -f "${HOME}/spack/share/spack/setup-env.sh" ]; then
    source "${HOME}/spack/share/spack/setup-env.sh"
    set +x
    spack load /f5r6h7z
    spack load openmpi@${craympich_ver}
    spack load netcdf-c@${netcdf_ver}
    spack load netcdf-fortran@${netcdf_fortran_ver}
    spack load /pdrsior  # ip@4.3.0
    spack load /52mczjo  # w3emc@2.10.0
    spack load bacio@${bacio_ver}
    spack load sp@${sp_ver}
    spack load g2@${g2_ver}
    spack load jasper@${jasper_ver}
    spack load libpng@${libpng_ver}
    spack load zlib@${zlib_ver}
    set -x

    # Library paths
    export LIBIP=$(spack location -i /pdrsior)/lib
    export LIBW3EMC=$(spack location -i /52mczjo)/lib
    export LIBBACIO=$(spack location -i bacio)/lib
    export LIBSP=$(spack location -i sp)/lib
    export LIBG2=$(spack location -i g2)/lib
    export LIBJASPER=$(spack location -i jasper)/lib
    export LIBPNG=/home/anilk/spack/opt/spack/linux-broadwell/libpng-1.6.47-vruwbg36jqzhv2dixl4wqxv3rjm2f2ih/lib
    export LIBZ=$(spack location -i zlib)/lib

    # Fortran compiler and flags
    export FC=mpifort
    export FFLAGS="-g -O2 -fconvert=big-endian -frecord-marker=4 -fno-second-underscore"
    if [ "$BUILD_DEBUG" = "YES" ]; then
        export FFLAGS="-g -O0 -fcheck=bounds -fconvert=big-endian -frecord-marker=4"
    fi
    export ENDIAN_FLAG="-fconvert=big-endian -frecord-marker=4"

    # Link libraries
    EXTRA_LIBS=" \
    ${LIBIP}/libip_4.a \
    ${LIBW3EMC}/libw3emc_4.a \
    ${LIBBACIO}/libbacio.a \
    ${LIBSP}/libsp_4.a \
    ${LIBG2}/libg2_4.a \
    ${LIBJASPER}/libjasper.so \
    ${LIBPNG}/libpng.so \
    ${LIBZ}/libz.so"
else
    echo "Spack environment not detected. Exiting."
    exit 1
fi

# Create or clean the exec directory
if [ ! -d "${EXECevs}" ]; then
    echo "Creating ${EXECevs}"
    mkdir -p "${EXECevs}"
elif [ "${BUILD_CLEAN}" = "YES" ]; then
    echo "Cleaning existing build at ${EXECevs}"
    rm -rf "${EXECevs}"
    mkdir -p "${EXECevs}"
else
    echo "Retaining existing build directory: ${EXECevs}"
fi

# Build each component
for code in ecm_gfs_look_alike_new jma_merge ukm_hires_merge pcpconform sref_precip evs_g2g_adjustCMC; do
    cd "${pkg_root}/sorc/${code}.fd"

    # Special link handling
    LIB_EXTRA=""
    if [[ "$code" == "sref_precip" || "$code" == "evs_g2g_adjustCMC" ]]; then
        LIB_EXTRA="-L${LIBJASPER} -ljasper -L${LIBPNG} -lpng -L${LIBZ} -lz"
    fi

    # Patch makefile flags
    sed -i "s/-convert big_endian/${ENDIAN_FLAG}/g" makefile || true
    sed -i 's/-traceback//g' makefile || true

    # Clean and build
    if [ "${BUILD_CLEAN}" = "YES" ]; then
        make VERBOSE="${BUILD_VERBOSE}" clean
    fi

    if [ "${BUILD_DEBUG}" = "YES" ]; then
        make VERBOSE="${BUILD_VERBOSE}" LIBS="${EXTRA_LIBS} ${LIB_EXTRA}" debug
    else
        make VERBOSE="${BUILD_VERBOSE}" LIBS="${EXTRA_LIBS} ${LIB_EXTRA}"
    fi

    make VERBOSE="${BUILD_VERBOSE}" LIBS="${EXTRA_LIBS} ${LIB_EXTRA}" install
done

