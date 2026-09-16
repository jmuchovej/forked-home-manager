{ config, ... }:
{
  programs.devenv = {
    enable = true;

    package = config.lib.test.mkStubPackage { name = "devenv"; };
  };

  nmt.script = ''
    assertPathNotExists home-files/.config/devenv/config.yaml
  '';
}
