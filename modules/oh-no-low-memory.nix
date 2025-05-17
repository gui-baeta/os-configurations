{ ... }:
{
  #
  # Enable Systemd unit generator for zram devices.
  #  Idk if I need this or if `zramSwap.enable = true` is enough
  services.zram-generator.enable = true;
  zramSwap = {
    enable = true;
    # memory that can be stored in the zram swap devices (RAM based block devices). SEE: https://www.kernel.org/doc/Documentation/blockdev/zram.txt
    # memoryPercent = 50; # % Percent - default 50
  };
  #
  # NOTE: enabling system bus notify makes the machine open to DoS attacks if other local users are mean and spam notifications.
  #
  # Enable System bus notification support
  services.systembus-notify.enable = true;
  #
  # Send notifications about killed processes via the system d-bus.
  services.earlyoom = {
    enable = true;
    enableNotifications = true;
    freeMemThreshold = 10; # % Percent - default 10
    # freeMemKillThreshold = 5; # default half of `freeMemThreshold`
    freeSwapThreshold = 10; # default 10
    # freeSwapKillThreshold = 5; # default half of `freeSwapThreshold`
  };
}
