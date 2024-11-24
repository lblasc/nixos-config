{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/nixos-unstable-small;
    tvbeat-ssh.url = github:tvbeat/tvbeat-ssh;
    tvbeat-ssh.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, tvbeat-ssh, ... }:
    {
      nixosConfigurations = {
        x1 = nixpkgs.lib.nixosSystem {
          specialArgs = { inherit nixpkgs tvbeat-ssh; };
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
