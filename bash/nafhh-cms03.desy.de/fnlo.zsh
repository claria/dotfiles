setfnlo () {
   FNLO=/nfs/dust/cms/user/gsieber/sw/fastnlo_toolkit
   export PATH=$FNLO/bin:$PATH
   export LD_LIBRARY_PATH=$FNLO/lib/:$LD_LIBRARY_PATH
   export PYTHONPATH=$FNLO/lib64/python2.6/site-packages:$PYTHONPATH
}
