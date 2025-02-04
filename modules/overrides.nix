{
  config,
  lib,
  pkgs,
  flake-inputs,
  ...
}:

{
  services.xserver.excludePackages = [ pkgs.xterm ];

  environment.gnome.excludePackages = (
    with pkgs;
    [
      gnome-tour
      snapshot
      orca
      seahorse # password manager
      totem # video player
      yelp
      gnome-maps
      gnome-music
      epiphany # web browser
      geary # email reader
      evolution
      gnome-clocks
      gnome-weather
      gnome-contacts
      gnome-calendar
      gnome-calculator
      gnome-backgrounds
    ]
  );

  services.gnome.evolution-data-server.enable = lib.mkForce false;
  services.gnome.gnome-initial-setup.enable = false;

  # See this for further reading and improvements: https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
  services.xserver.desktopManager.gnome = {
    extraGSettingsOverrides = ''
      # Change default screensaver settings
      [org.gnome.desktop.screensaver]
      lock-enabled=true

      [org.gnome.desktop.wm.preferences]
      audible-bell=false
      resize-with-right-button=true

      [org.gnome.desktop.input-sources]
      sources=[('xkb', 'pt')]
      xkb-options=['terminate:ctrl_alt_bksp']

      [org.gnome.desktop.interface]
      gtk-enable-primary-paste=false
      show-battery-percentage=false
      text-scaling-factor=1.25
      show-battery-percentage=false

      [org.gnome.shell]
      disabled-extensions=['apps-menu@gnome-shell-extensions.gcampax.github.com', 'auto-move-windows@gnome-shell-extensions.gcampax.github.com', 'places-menu@gnome-shell-extensions.gcampax.github.com', 'native-window-placement@gnome-shell-extensions.gcampax.github.com', 'window-list@gnome-shell-extensions.gcampax.github.com', 'workspace-indicator@gnome-shell-extensions.gcampax.github.com']
      disable-user-extensions=false
      enabled-extensions=['caffeine@patapon.info', 'clipboard-history@alexsaveau.dev', 'gsconnect@andyholmes.github.io', 'blur-my-shell@aunetx']
      favorite-apps=['firefox.desktop', 'org.gnome.Nautilus.desktop', 'spotify.desktop']
      remember-mount-password=false

      [org.gnome.shell.weather]
      automatic-location=true
      locations=[<(uint32 2, <('Lisbon', 'LPPT', true, [(0.6766059791742326, -0.15940673253105125)], [(0.67573331454823549, -0.15940673253105125)])>)>]

      [org.gnome.shell.window-switcher]
      current-workspace-only=true

      [org.gnome.shell.extensions.blur-my-shell.panel]
      blur=false

      [org.gnome.shell.extensions.blur-my-shell.window-list]
      blur=true
      brightness=0.59999999999999998
      sigma=30

      [org.gnome.shell.extensions.blur-my-shell.applications]
      blur=false

      [org.gnome.shell.extensions.blur-my-shell]
      pipelines={'pipeline_default': {'name': <'Default'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_06304838404041'>, 'params': <@a{sv} {}>}>]>}, 'pipeline_default_rounded': {'name': <'Default rounded'>, 'effects': <[<{'type': <'native_static_gaussian_blur'>, 'id': <'effect_000000000001'>, 'params': <{'radius': <30>, 'brightness': <0.59999999999999998>}>}>, <{'type': <'corner'>, 'id': <'effect_000000000002'>, 'params': <{'radius': <24>}>}>]>}}

      [org.gnome.shell.extensions.clipboard-history]
      confirm-clear=false
      paste-on-selection=false

      # 1st line - If the ambient light sensor functionality is enabled.
      [org.gnome.settings-daemon.plugins.power]
      ambient-enabled=false
      idle-dim=true
      power-saver-profile-on-low-battery=true
      sleep-inactive-ac-type='nothing'

      [org.gnome.settings-daemon.plugins.color]
      night-light-schedule-automatic=true
      night-light-temperature=3013
    '';

    extraGSettingsOverridePackages = [
      pkgs.gsettings-desktop-schemas # for org.gnome.desktop
      pkgs.gnome-shell # for org.gnome.shell
      pkgs.gnome-settings-daemon # for org.gnome.settings-daemon
    ];
  };
}
