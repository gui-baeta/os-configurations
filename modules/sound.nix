{ config, pkgs, flake-inputs, ... }:

{
  # hardware.bluetooth.enable = true;
  security.rtkit.enable = true;
  
  hardware.pulseaudio.enable = false;
  # Enable sound with pipewire.
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