{
  description = "system level services of a well-functioning Linux desktop (risky to turn off)";
  default = true;
  packages = [
    "dconf"
    "udev"
    "dbus"
    "rtkit"
    "lm_sensors"
  ];
}
