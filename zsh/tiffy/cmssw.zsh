
cmssw_env ()
{
   export SCRAM_ARCH=slc6_amd64_gcc472
   export VO_CMS_SW_DIR=/afs/cern.ch/cms
   source $VO_CMS_SW_DIR/cmsset_default.sh
   CMSSW_BASE="/home/aem/uni/sw"
   case $1 in
      537) CMSSWDIR="$CMSSW_BASE/CMSSW_5_3_7_patch6";;
      539) CMSSWDIR="$CMSSW_BASE/CMSSW_5_3_9";;
      611) CMSSWDIR="$CMSSW_BASE/CMSSW_6_1_1";;
      626) CMSSWDIR="$CMSSW_BASE/CMSSW_6_2_6";;
        *) CMSSWDIR="$CMSSW_BASE/CMSSW_6_2_6";;
   esac

   eval `(cd $CMSSWDIR && scramv1 runtime -sh)`
}
