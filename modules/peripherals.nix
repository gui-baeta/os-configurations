{ pkgs, ... }:
{
  #
  # ================
  # Logitech stuff
  # ================
  #
  # Logitech Devices (Mouse, etc)
  hardware.logitech.wireless.enable = true;
  #
  # this line enables solaar
  hardware.logitech.wireless.enableGraphical = true;
  services.solaar = {
    enable = true; # Enable the service
    # TEST: default is the solaar flake
    # package = pkgs.solaar; # The package to use
    window = "hide"; # Show the window on startup (show, *hide*, only [window only])
    batteryIcons = "regular"; # Which battery icons to use (*regular*, symbolic, solaar)
    extraArgs = ""; # Extra arguments to pass to solaar on startup
  };
  #
  # ================
  # Steam Controller stuff
  # ================
  #
  #
  # support Steam Input better - translate input events from X11 to uinput events
  programs.steam.extest.enable = true;
  #
  # enable udev rules and add uinput to boot.kernelModules
  hardware.steam-hardware.enable = true;
  #
  # Enable uinput support
  hardware.uinput.enable = true;
  #
  # udev rules for Steam Controller
  services.udev.extraRules = ''
    # Valve generic(all) USB devices
    SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"

    # Valve HID devices; Bluetooth; USB
    KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0660", TAG+="uaccess"

    # Valve HID devices over USB hidraw
    KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0660", TAG+="uaccess"

    # Steam Controller udev write access
    KERNEL=="uinput", SUBSYSTEM=="misc", TAG+="uaccess"

    # NOTE: UNCOMMENT & TEST IF THIS IMPROVES ANYTHING
    #
    # This rule is necessary for gamepad emulation; make sure each user requiring
    # it is part of the input group.
    # KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
  '';

}
