
function touchpad() {
case $1 in
	on )
		synclient TouchpadOff=0;;
	off )
		synclient TouchpadOff=1;;
esac
}
