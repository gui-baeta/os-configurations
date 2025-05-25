{ options, pkgs, ... }:
{
  imports = [ ./steam.nix ];

  # Extra Packages for Linking
  programs.nix-ld.libraries =
    options.programs.nix-ld.libraries.default
    ++ (with pkgs; [
      stdenv.cc.cc
      openssl
      xorg.libXcomposite
      xorg.libXtst
      xorg.libXrandr
      xorg.libXext
      xorg.libX11
      xorg.libXfixes
      libGL
      libva
      pipewire
      xorg.libxcb
      xorg.libXdamage
      xorg.libxshmfence
      xorg.libXxf86vm
      libelf
      libuv
      libuvc
      libgudev
      speex
      libvdpau
      gst_all_1.gstreamer
      gst_all_1.gst-vaapi
      gst_all_1.gst-libav
      gst_all_1.gstreamermm
      gst_all_1.gst-devtools
      gst_all_1.icamerasrc-ipu6
      gst_all_1.gst-rtsp-server
      gst_all_1.gst-plugins-bad
      gst_all_1.gst-plugins-ugly
      gst_all_1.gst-plugins-good
      gst_all_1.gst-plugins-base
      gst_all_1.icamerasrc-ipu6ep
      gst_all_1.icamerasrc-ipu6epmtl
      gst_all_1.gst-editing-services

      libxcrypt
      gamemode

      # Required
      glib
      gtk2
      bzip2

      # Without these it silently fails
      xorg.libXinerama
      xorg.libXcursor
      xorg.libXrender
      xorg.libXScrnSaver
      xorg.libXi
      xorg.libSM
      xorg.libICE
      gnome2.GConf
      nspr
      nss
      cups
      libcap
      SDL2
      libusb1
      dbus-glib
      ffmpeg
      # Only libraries are needed from those two
      libudev0-shim

      # Verified games requirements
      xorg.libXt
      xorg.libXmu
      libogg
      libvorbis
      SDL
      SDL2_image
      glew110
      libidn
      tbb

      # Other things from runtime
      flac
      freeglut
      libjpeg
      libpng
      libpng12
      libsamplerate
      libmikmod
      libtheora
      libtiff
      pixman
      speex
      SDL_image
      SDL_ttf
      SDL_mixer
      SDL2_ttf
      SDL2_mixer
      libappindicator-gtk2
      libdbusmenu-gtk2
      libindicator-gtk2
      libcaca
      libcanberra
      libgcrypt
      libvpx
      librsvg
      xorg.libXft
      libvdpau
      pango
      cairo
      atk
      gdk-pixbuf
      fontconfig
      freetype
      dbus
      alsa-lib
      expat
      # Needed for electron
      libdrm
      mesa
      libxkbcommon
    ]);
}
