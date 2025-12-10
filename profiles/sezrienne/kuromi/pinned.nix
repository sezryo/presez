
{ config, pkgs, lib, inputs, ... }:

{
  system.stateVersion = "22.05";
  
  user.defaultPublicKey = "D931EC7A9950B57B";
  
  modules = {
    users = {
      users.enable = true;
      dotfiles.enable = true;
      home.enable = true;
    };

    shell = {
      enable = true;
      env = [ "nushell" "xonsh" "fish" "bash" "babashka" ];
      defaultShell = "nushell";
      loginShell = "xonsh";
      tools.enable = true;
      integration.enable = true;
    };
      
    desktop = {
      # hyprland-primary = {
	    #   enable = true;
	    #   version = "tokyo";
      # };
      wayland = {
        enable = true;
        minimum = true;
      };
      xserver = {
        touchpad = {
          enable = true;
          wacom = true;
        };
        wm = {
          enable = true;
          minimum = true;
        };
      };
      gtk = {
        enable = true;
        enableDefault = true;
        enableApps = true;
        gnome.enable = true;
        gnome.enableDefaultExtensions = true;
      };
      qt = {
        enable = true;
        theme = "catppuccin";
      };
       display = {
        enable = true;
        package = "gdm";
      };
      cursor = "catppuccin";
    };
    
    io = {
      audio = {
        enable = true;
        enableApps = true;
      };
      udisk.enable = true;
      monitor.enable = true;
      virtualisation = {
        enable = true;
        qemu = true;
      };
      bluetooth.enable = true;
      media.enable = true;
      printing.enable = true;
    };

    network = {
      # proxy = {
      #   enable = true;
      #   clash.enable = true;
      #   protonvpn.enable = true;
      # };
      nm = {
        enable = true;
        iwd.enable = false;
      };
      ssh.enable = true;
      usb = {
        enable = true;
        thunderbolt = true;
      };
    };
    
    hardware = {
      ga402rk.enable = true;
      vfio.enable = true;
    };

    nix = {
      # localise.enable = true; # TODO: Problems to be addressed
      gc.enable = true;
      channel = "unstable";
    };
    
    boot = {
      systemd-boot.enable = false;
      grub = {
        enable = true;
        efi = true;
        theme = "darkmatter-theme";
      };
      tty = {
        enable = true;
        theme = "catppuccin";
      };
      kernel = "latest";
    };

    general = {
      system.enable = true;
      core.enable = true;
      terminal = {
        enable = true;
        env = [ "alacritty" "wezterm" ];
        defaultTerminal = "wezterm";
      };
      gaming = {
        enable = true;
        gamescope = true;
        emulators = true;
        osu = true;
      };
      firefox = {
        enable = true;
        enableDefault = true;
      };
      pdf.enable = true;
      productivity.enable = true;
      maths.enable = true;
      social.enable = true;
      streaming.enable = true;
    };

    dev = {
      bundle.enable = true;
    };

    locale = {
      enable = true;
      defaultFonts = true;
      china = {
        enable = true;
      };
      uk = {
        enable = true;
        reside = true;
        spirit = true;
      };
      japan = {
        enable = true;
      };
    };

    security = {
      # u2f = {
      #   enable = true;
      #   yubikey = true;
      # };
      tpm.enable = true;
      encryption ={
        enable = true;
        yubikey = true;
      };
      kali.enable = true;
    };
  };
}
      
