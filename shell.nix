let
  pkgs = import ./package-lock.nix;
in with pkgs;
stdenv.mkDerivation {
  name = "daffy";
  buildInputs = import ./default.nix;
}
