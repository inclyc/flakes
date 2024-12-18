use std::env;
use std::fs;
use std::path::Path;

fn main() {
    // Take the isolating device from argv[1]
    let isolating_device = env::args().nth(1).expect("No device specified");

    let sys_bus_pci = Path::new("/sys/bus/pci");

    let iommu_group_path = sys_bus_pci
        .join("devices")
        .join(&isolating_device)
        .join("iommu_group")
        .join("devices");

    let iommu_group = fs::read_dir(&iommu_group_path).expect("Failed to read iommu group");

    for entry in iommu_group {
        let file_name = entry.expect("Failed to read entry").file_name();
        let device = file_name.to_str().unwrap();

        let device_dir = sys_bus_pci.join("devices").join(device);

        let driver_path = device_dir.join("driver");
        let driver = fs::read_link(&driver_path).unwrap_or_default();

        if driver.to_string_lossy().contains("vfio-pci") {
            println!("skip({}): this device is already bound to vfio-pci", device);
            continue;
        }

        // Remove from previous driver
        if device_dir.join(&driver).exists() {
            println!("driver/remove({}): remove from previous driver ...", device);
            let _ = fs::write(device_dir.join("driver/unbind"), device);
        }

        // Bind to vfio-pci
        println!("bind ...");
        fs::write(device_dir.join("driver_override"), "vfio-pci")
            .expect("driver/override: Failed to write driver_override");

        // Probe device
        println!("probe({}) ...", device);
        fs::write("/sys/bus/pci/drivers_probe", device).expect("Failed to probe device");
    }
}
