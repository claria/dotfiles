# Store grid proxy in afs area
export X509_USER_PROXY=$HOME/.globus/x509up

# Setup a scram environment
scramenv () {
    if [ $# -eq 0 ]; then
        export SCRAM_ARCH=slc6_amd64_gcc481
        echo "Set default scram arch ${SCRAM_ARCH}"
    elif [ $# -eq 1 ]; then
        export SCRAM_ARCH=slc6_amd64_gcc${1}
        echo "Set scram arch ${SCRAM_ARCH}"
    elif [ $# -eq 2 ]; then
        export SCRAM_ARCH=${1}_amd64_gcc${2}
        echo "Set scram arch ${SCRAM_ARCH}"

    fi
    export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
    source $VO_CMS_SW_DIR/cmsset_default.sh
}

# Setup default CMSSW env
cmssw_env () {
    if [ -z "${SCRAM_ARCH}" ]; then
        echo "No SCRAM_ARCH set."
        echo "Use default SCRAM_ARCH"
        scramenv
    fi
    if [ $# -eq 0 ]; then
        CMSSW_DIR="/nfs/dust/cms/user/gsieber/dijetana/ana/CMSSW_7_2_3"
        echo "Use default CMSSW dir in ${CMSSW_DIR}"
    elif [ $# -eq 1 ]; then
        CMSSW_DIR="${1}"
        echo "Use CMSSW dir in ${CMSSW_DIR}"
    fi

    echo "Setup a CMSSW env"
    eval `(cd $CMSSW_DIR && scramv1 runtime -sh)`
}
