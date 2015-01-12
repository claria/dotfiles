# Store grid proxy in afs area
export X509_USER_PROXY=$HOME/.globus/x509up

# Setup a scram environment
scramenv () {
    export SCRAM_ARCH=slc6_amd64_gcc481
    # export VO_CMS_SW_DIR=/afs/cern.ch/cms
    export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
    source $VO_CMS_SW_DIR/cmsset_default.sh
}

# Setup default CMSSW env
cmssw_env () {
    scramenv
    echo "Setup a CMSSW_7_1_5 env"
    CMSSWDIR="/afs/desy.de/user/g/gsieber/dijetana/ana/CMSSW_7_1_5"
    eval `(cd $CMSSWDIR && scramv1 runtime -sh)`
}
