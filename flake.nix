{
  inputs = {
    sops-nix.url = github:Mic92/sops-nix;
    nixpkgs.url = github:NixOS/nixpkgs/master;
  };

  outputs = { self, nixpkgs, sops-nix }:
    let
      overlay = final: prev: {
        e = true;
      };
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
            ./x1/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
        merovingian = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          inherit pkgs;
          modules = [
            ./merovingian/configuration.nix
            sops-nix.nixosModules.sops
          ];
        };
      };
    };
}
