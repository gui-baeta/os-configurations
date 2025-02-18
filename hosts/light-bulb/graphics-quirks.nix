{
  ...
}:
{
  # Dynamic power management may cause *screen artifacts* to appear
  # when displaying to *monitors at higher frequencies* (anything *above 60Hz*)
  # due to issues in the way GPU clock speeds are managed
  services.udev.extraRules = ''
    KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_force_performance_level}="high"
    KERNEL=="card1", SUBSYSTEM=="drm", DRIVERS=="amdgpu", ATTR{device/power_dpm_state}="performance"
  '';
}
