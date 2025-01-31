{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/master;
    tvbeat-ssh.url = github:tvbeat/tvbeat-ssh;
    tvbeat-ssh.inputs.nixpkgs.follows = "nixpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = { self, nixpkgs, tvbeat-ssh, nixos-hardware, ... }:
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
        fw = nixpkgs.lib.nixosSystem {
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
            ./fw/configuration.nix
            nixos-hardware.nixosModules.framework-intel-core-ultra-series1
          ];
        };
      };
    };
}
