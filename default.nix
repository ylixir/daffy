let
  pkgs = import ./package-lock.nix;
in with pkgs;
[
  lua5_4
  gnumake
]
