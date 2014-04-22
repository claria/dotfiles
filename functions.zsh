#FastNLO Python bindings
function setfnlo()
{
	FNLO="/home/aem/uni/sw/fnloreader/"
	export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$FNLO/lib
	export PYTHONPATH=$PYTHONPATH:$FNLO/lib/python2.7/site-packages
}
