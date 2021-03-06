if [ "$(adb get-state)" != "device" ]
then 
  echo "Your USB devices:"
  lsusb
  adb devices
  echo "+============================================+"
  echo "| You need to connect your device right now. |"
  echo "| Please plug the device in and try again.   |"
  echo "+============================================+"
  exit 1
fi

#flash phone
DEVICE=`adb shell getprop ro.product.device 2> /dev/null`
DEVICE=${DEVICE:-aries}
DEVICE=`echo ${DEVICE} | tr -d '\r'`
NAMESPACE=gecko.v2.mozilla-central.latest.b2g.$DEVICE-eng-opt 
ARTIFACT=private/build/$DEVICE.zip
DEST_DIR=~/builds
mkdir $DEST_DIR
taskcluster_download -n $NAMESPACE -a $ARTIFACT -d $DEST_DIR
cd $DEST_DIR
unzip $DEVICE.zip
cd b2g-distro
adb kill-server
sudo adb start-server
./flash.sh

SCRIPT_PATH="`dirname \"$0\"`"

$SCRIPT_PATH/gij_provision.sh
pushd ~/gaia
DEVICE_DEBUG=1 make reset-gaia
REBOOT_TIME=1 #min
echo "Waiting for the device to boot ($REBOOT_TIME min)..."
sleep ${REBOOT_TIME}m
popd

export BUILDAPP=device
export GIJ_NO_SETUP=1
# DEVICE_DEBUG=1 make reset-gaia
$SCRIPT_PATH/gij_phone_mulet.sh

adb reboot
