{ overlays ? [ ]
, config ? { }
}:
let
  sources = import ./sources.nix;
  nixpkgsSrc = sources.nixpkgs;
  pkgsSrc = ./.;

  nixpkgs = import nixpkgsSrc {
    config = config;
    overlays = [
      (self: super: { inherit sources; })
      # local overlay
      (import ./overlay)
    ] ++ overlays;
  };

  # Combine local `pkgs` expressions with `nixos` modules
  # from `nixpkgs`. Nixos modules needs to be available
  # in NIX_PATH or nixos-rebuild won't be able to find them.
  combinedSrc = nixpkgs.runCommand "combinedSrc" { } ''
    mkdir $out
    ln -s ${pkgsSrc}/* $out/
    ln -s ${nixpkgsSrc}/nixos $out/nixos
  '';
in
nixpkgs // {
  nixpkgsSrc = combinedSrc;
}
