{ ... }:
{
  # about:config options that could be interested to set:
  #
  #
  # # Disables the context menu (three-dot menu) in Firefox's address bar search suggestions
  # browser.urlbar.resultMenu = false
  # # Ensures keyboard navigation through search suggestions works smoothly without additional interactions
  # browser.urlbar.resultMenu.keyboardAccessible = false  #
  #
  # - browser.urlbar.showSearchSuggestionsFirst = true
  # - browser.urlbar.deduplication.enabled = true
  # - browser.tabs.unloadOnLowMemory = true;
  # - browser.tabs.min_inactive_duration_before_unload = 7200; # (I think this is seconds)
  #
  # Stuff I dont want
  # - browser.newtabpage.activity-stream.improvesearch.topSiteSearchShortcuts
  # - browser.newtabpage.activity-stream.showSponsoredTopSites = false
  # - browser.newtabpage.activity-stream.showSponsored = false
  # - browser.newtabpage.activity-stream.weather.locationSearchEnabled = false
  # - browser.vpn_promo.enabled = false
  # Disable Pocket:
  #  user_pref("extensions.pocket.enabled", false);
  #  user_pref("extensions.pocket.api", "0.0.0.0");
  #  user_pref("extensions.pocket.loggedOutVariant", "");
  #  user_pref("extensions.pocket.oAuthConsumerKey", "");
  #  user_pref("extensions.pocket.onSaveRecs", false);
  #  user_pref("extensions.pocket.onSaveRecs.locales", "");
  #  user_pref("extensions.pocket.showHome", false);
  #  user_pref("extensions.pocket.site", "0.0.0.0");
  #  user_pref("browser.newtabpage.activity-stream.pocketCta", "");
  #  user_pref("browser.newtabpage.activity-stream.section.highlights.includePocket", false);
  #  user_pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket", false);
  #  user_pref("services.sync.prefs.sync-seen.services.sync.prefs.sync.browser.newtabpage.activity-stream.section.highlights.includePocket", false);
  # Disable "Recommended by Pocket" in Firefox Quantum
  #  user_pref("browser.newtabpage.activity-stream.feeds.section.topstories", false);
  #  user_pref("services.sync.prefs.sync.browser.newtabpage.activity-stream.feeds.section.topstories", false);
}
