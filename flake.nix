{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable;
  };

  outputs = { self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        x1 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit nixpkgs; };
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            overlays = [
              (import ./pkgs/overlay)
            ];
            config.allowUnfree = true;
          };
          modules = [
            ./common.nix
            ./x1/configuration.nix
          ];
        };
      };
    };
}
