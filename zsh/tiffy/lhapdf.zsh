function setlhapdf()
{
	LHAPDF=/home/aem/uni/sw/lhapdf/
	export LHAPATH=/home/aem/uni/sw/lhapdf/share/lhapdf/PDFsets
	export PATH=$LHAPDF/bin:$PATH
	export LD_LIBRARY_PATH=$LHAPDF/lib/:$LD_LIBRARY_PATH
	export PYTHONPATH=$LHAPDF/lib/python2.7/site-packages:$PYTHONPATH
}

function setlhapdf6()
{
	LHAPDF=/home/aem/uni/sw/lhapdf6/
	export LHAPDF_DATA_PATH=$LHAPDF/share/LHAPDF/
	export PATH=$LHAPDF/bin:$PATH
	export LD_LIBRARY_PATH=$LHAPDF/lib/:$LD_LIBRARY_PATH
	export PYTHONPATH=$LHAPDF/lib/python2.7/site-packages:$PYTHONPATH
}
