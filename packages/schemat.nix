{ pname, pkgs, ... }:
pkgs.rustPlatform.buildRustPackage {
  inherit pname;
  version = "0.2.14";

  src = pkgs.fetchFromGitHub {
    owner = "raviqqe";
    repo = pname;
    rev = "ea9bcb6545214a70ce93a5c49c229f430ab58c2e"; # as of 2025-01-22
    hash = "sha256-h8JjT1cspfpuLII2hBMVRiPMDoC2hV8e8SVykWVkkys=";
  };

  # FIXME: This should really be removed in favor of using a proper nightly
  # toolchain, but it works for now. Might need to use rust-overlay?
  RUSTC_BOOTSTRAP = true;

  useFetchCargoVendor = true;
  cargoHash = "sha256-ZKy+voOLROK1S5YD8b8i5/pXZXnQn2ZBarFsUjYThPY=";

  meta = {
    description = "Code formatter for Scheme, Lisp, and any S-expressions";
    homepage = "github.com/raviqqe/schemat";
    license = pkgs.lib.licenses.unlicense;
    maintainers = [ ];
  };
}
