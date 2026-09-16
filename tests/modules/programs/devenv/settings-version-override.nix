{ config, ... }:
{
  programs.devenv = {
    enable = true;

    package = config.lib.test.mkStubPackage { name = "devenv"; };

    settings.version = 2;
  };

  nmt.script = ''
    assertFileExists home-files/.config/devenv/config.yaml
    assertFileRegex home-files/.config/devenv/config.yaml '^version: 2$'
  '';
}
