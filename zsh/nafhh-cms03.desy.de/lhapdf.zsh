setlhapdf () {
   LHAPDF=/nfs/dust/cms/user/gsieber/sw/lhapdf
   export LHAPATH=/nfs/dust/cms/user/gsieber/lhgrids
   export PATH=$LHAPDF/bin:$PATH
   export LD_LIBRARY_PATH=$LHAPDF/lib/:$LD_LIBRARY_PATH
   export PYTHONPATH=$LHAPDF/lib/python2.7/site-packages:$PYTHONPATH
}
