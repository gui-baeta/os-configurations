{config, pkgs, lib, ... }:

{
  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
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
    
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
}