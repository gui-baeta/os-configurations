{ userInf, pkgs, ... }:
{
  services.navidrome = {
    enable = true;
    openFirewall = true;
    settings = {
      Address = "0.0.0.0";
      Port = 4533;
      MusicFolder = "${userInf.homeDir}/Music/navidrome/music";
      DataFolder = "${userInf.homeDir}/Music/navidrome/data";
      CacheFolder = "${userInf.homeDir}/Music/navidrome/data/cache";
      AutoImportPlaylists = true;
      EnableInsightsCollector = false;
      Jukebox.Enabled = false;
    };
  };
}
