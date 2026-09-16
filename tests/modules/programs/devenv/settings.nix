{ config, ... }:
{
  programs.devenv = {
    enable = true;

    package = config.lib.test.mkStubPackage { name = "devenv"; };

    settings = {
      tui = {
        viewport = "top";
        theme.preset = "terminal";
        behavior = {
          mouse = false;
          log_preview_lines = 20;
        };
      };
      shell.prompt_prefix = false;
    };
  };

  nmt.script = ''
    assertFileExists home-files/.config/devenv/config.yaml
    assertFileContent home-files/.config/devenv/config.yaml ${./settings.yaml}
  '';
}
