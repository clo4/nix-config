{
  pkgs,
  pname,
  perSystem,
  flake,
}:
if pkgs.system != "x86_64-linux" then
  pkgs.emptyFile
else
  pkgs.writeShellScriptBin pname ''
    ${perSystem.disko.disko-install}/bin/disko-install --flake path:${flake}#homeserver1 --disk main /dev/nvme0n1
  ''
