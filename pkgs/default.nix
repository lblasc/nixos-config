{ overlays ? []
, config ? {} }:

let
  sources = import ./sources.nix;
  nixpkgsSrc = sources.nixpkgs;
  pkgsSrc = ./.;

  nixpkgs = import nixpkgsSrc {
    config = config;
    overlays = [
      # local overlay
      (import ./overlay)
    ] ++ overlays;
  };
  combinedSrc = nixpkgs.runCommand "combinedSrc" {} ''
    mkdir $out
    ln -s ${pkgsSrc}/* $out/
    ls -la $out/
    ln -s ${nixpkgsSrc}/nixos $out/nixos
    ls -la $out/
  '';
in nixpkgs // {
  nixpkgsSrc = combinedSrc;
}
