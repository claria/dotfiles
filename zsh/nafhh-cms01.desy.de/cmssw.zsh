cmsswenv () {

   export SCRAM_ARCH=slc5_amd64_gcc462
   export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
   source $VO_CMS_SW_DIR/cmsset_default.sh

   CMSSW_BASE="/afs/desy.de/user/g/gsieber/dust/sw"
   case $1 in
      537) CMSSWDIR="$CMSSW_BASE/CMSSW_5_3_7_patch6";;
      539) CMSSWDIR="$CMSSW_BASE/CMSSW_5_3_9";;
      611) CMSSWDIR="$CMSSW_BASE/CMSSW_6_0_1";;
        *) CMSSWDIR="$CMSSW_BASE/CMSSW_6_0_1";;
   esac

   eval `(cd $CMSSWDIR && scramv1 runtime -sh)`
}

scramenv () {

   export SCRAM_ARCH=slc5_amd64_gcc472
   export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
   source $VO_CMS_SW_DIR/cmsset_default.sh

}
scram_env_old () {

   export SCRAM_ARCH=slc5_amd64_gcc472
   export VO_CMS_SW_DIR=/cvmfs/cms.cern.ch
   source $VO_CMS_SW_DIR/cmsset_default.sh

}
