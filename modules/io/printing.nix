{
  description = "printing services";
  packages = [
    "avahi"
    "ipp-usb" # for a USB printer
  ];
  config = {
    services.printing.enable = true;
  };
}
