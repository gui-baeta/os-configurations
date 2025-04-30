{ config, ... }:
{
  sops.secrets."smartcat/groq" = { };
  sops.secrets."smartcat/anthropic" = { };
  sops.secrets."smartcat/mistral" = { };
  # sops.templates."smartcat-api_configs.toml".content = ''
  #   password = "${config.sops.placeholder.your-secret}"
  # '';
  #
  # smartcat tool dotfiles configurations
  # SEE: https://github.com/efugier/smartcat?tab=readme-ov-file#Configuration
  #
  home.file = {
    ".config/smartcat/prompts.toml".source = ./prompts.toml;
    ".config/smartcat/.api_configs.toml".text = ''
      [groq]
      api_key_command = "cat ${config.sops.secrets."smartcat/groq".path}"
      # api_key_command = "echo $MY_GROQ_API_KEY"
      default_model = "llama3-70b-8192"
      url = "https://api.groq.com/openai/v1/chat/completions"

      [anthropic]
      api_key_command = "cat ${config.sops.secrets."smartcat/anthropic".path}"
      url = "https://api.anthropic.com/v1/messages"
      default_model = "claude-3-5-haiku-20241022"
      version = "2023-06-01"  # anthropic API version, see https://docs.anthropic.com/en/api/versioning

      [mistral]
      api_key_command = "cat ${config.sops.secrets."smartcat/mistral".path}"
      default_model = "mistral-large-latest"
      url = "https://api.mistral.ai/v1/chat/completions"
    '';
    #
    # NOTE Auto-managed
    # ".config/smartcat/conversation.toml".source =
    #   config.lib.file.mkOutOfStoreSymlink ./conversation.toml;
  };
}
