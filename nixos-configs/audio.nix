{ config, pkgs, lib, ... }:

{
  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  # TODO Remove? Is it on by default?
  # hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;

    alsa = {
      enable = true;
      support32Bit = true;
    };

    # Enable audio through pipewire
    audio.enable = true;
    pulse.enable = true;
  };
}
