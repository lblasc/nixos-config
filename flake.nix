{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/master;
    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix }:
    let
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config.allowUnfree = true;
        overlays = [ (import ./pkgs/overlay) ];
      };
    in
    {
      nixosConfigurations = {
        x1 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;
          modules = [
            ./common.nix
            ./x1/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
        merovingian = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;
          modules = [
            ./common.nix
            ./merovingian/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
