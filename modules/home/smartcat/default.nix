{ config, ... }:
{
  #
  # smartcat tool dotfiles configurations
  # SEE: https://github.com/efugier/smartcat?tab=readme-ov-file#Configuration
  #

  home.file = {
    ".config/smartcat/.api_configs.toml".source = ./.api_configs.toml;
    ".config/smartcat/prompts.toml".source = ./prompts.toml;
    #
    # NOTE Auto-managed
    # ".config/smartcat/conversation.toml".source =
    #   config.lib.file.mkOutOfStoreSymlink ./conversation.toml;
  };
}
