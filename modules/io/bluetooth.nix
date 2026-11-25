{
  description = "Bluetooth and its tools";
  packages = [
    "bluez"
    "bluez-tools"
    "blueman"
  ];
  config = {
    hardware.bluetooth.enable = true;
  };
}
