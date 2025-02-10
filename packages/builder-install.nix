{
  pkgs,
  pname,
  perSystem,
  flake,
}:
pkgs.writeShellScriptBin pname ''
  ${perSystem.disko.disko-install}/bin/disko-install --flake path:${flake}#builder --disk main /dev/vda
''
