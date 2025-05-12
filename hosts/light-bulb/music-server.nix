{ pkgs, ... }:
{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "/home/guibaeta/Music/navidrome/music";
      DataFolder = "/home/guibaeta/Music/navidrome/data";
      CacheFolder = "/home/guibaeta/Music/navidrome/data/cache";
      AutoImportPlaylists = true;
      EnableInsightsCollector = false;
      Jukebox.Enabled = false;
    };
  };
}
