{
  modules = {
    shell = {
      env = [ "nushell" "xonsh" "fish" "bash" "babashka" ];
    };

    hardware = {
      ga402rk.enable = true;
      vfio.enable = true;
    };

    boot = {
      tty.theme = "catppuccin";
    };
  };
}
