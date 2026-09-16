{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkOption
    mkPackageOption
    mkIf
    mkAfter
    getExe
    literalExpression
    types
    ;

  cfg = config.programs.devenv;

  yamlFormat = pkgs.formats.yaml { };

  # `version` is the only key devenv requires, so on its own it carries no user
  # intent; it doubles as the marker for "nothing was configured".
  defaultSettings = {
    version = 1;
  };

in
{
  meta.maintainers = with lib.maintainers; [
    leiserfg
  ];

  options.programs.devenv = {
    enable = mkEnableOption "devenv, Fast, Declarative, Reproducible and Composable Developer Environments using Nix";

    package = mkPackageOption pkgs "devenv" { };

    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };

    enableFishIntegration = lib.hm.shell.mkFishIntegrationOption { inherit config; };

    enableNushellIntegration = lib.hm.shell.mkNushellIntegrationOption { inherit config; };

    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };

    settings = mkOption {
      type = types.submodule {
        freeformType = yamlFormat.type;

        options.version = mkOption {
          type = types.ints.positive;
          default = defaultSettings.version;
          description = ''
            Schema version of the user configuration file.
          '';
        };
      };
      default = { };
      example = literalExpression ''
        {
          tui = {
            viewport = "top";
            theme.preset = "terminal";
            behavior.mouse = false;
          };
          shell.prompt_prefix = false;
        }
      '';
      description = ''
        User configuration written to
        {file}`$XDG_CONFIG_HOME/devenv/config.yaml`.

        See <https://devenv.sh/tui-customization/> for supported values.

        Note, no file is written unless something beyond
        [](#opt-programs.devenv.settings.version) is set.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."devenv/config.yaml" = mkIf (cfg.settings != defaultSettings) {
      source = yamlFormat.generate "devenv-config.yaml" cfg.settings;
    };

    programs = {
      bash.initExtra = mkIf cfg.enableBashIntegration (mkAfter ''
        eval "$(${getExe cfg.package} hook bash)"
      '');

      fish.interactiveShellInit = mkIf cfg.enableFishIntegration (mkAfter ''
        ${getExe cfg.package} hook fish | source
      '');

      zsh.initContent = mkIf cfg.enableZshIntegration ''
        eval "$(${getExe cfg.package} hook zsh)"
      '';

      nushell = mkIf cfg.enableNushellIntegration {
        extraConfig = "source ${
          pkgs.runCommand "devenv-nushell-config.nu" { } ''
            ${getExe cfg.package} hook nu > $out
          ''
        } ";
      };
    };
  };
}
