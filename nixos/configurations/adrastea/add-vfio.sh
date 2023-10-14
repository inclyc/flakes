# add-vfio.sh: detect iommu groups and override the driver of these devices to vfio-pci

IsolatingDevice="$1"

IOMMUGroup=$(ls "/sys/bus/pci/devices/$IsolatingDevice/iommu_group/devices")

for Device in ${IOMMUGroup}; do
    DeviceDir="/sys/bus/pci/devices/$Device"
    Driver=$(readlink -f "$DeviceDir/driver")
    echo "check: $(lspci -nns $Device)..."

    if  [[ $Driver =~ "vfio-pci" ]]; then
        echo "skip: this device is already binded to vfio-pci"
        continue
    fi


    # Remove it from previous binded driver
    if [ -d "$DeviceDir/driver" ]; then
        echo "remove it from previous driver ..."
        echo "$Device" > "$DeviceDir/driver/unbind"
    fi

    # Bind it to vfio-pci
    echo "bind ... "
    echo 'vfio-pci' > "$DeviceDir/driver_override"
    echo "probe ... "
    echo "$Device" > /sys/bus/pci/drivers_probe
done
