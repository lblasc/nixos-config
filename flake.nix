{
  inputs = {
    nixpkgs.url = github:NixOS/nixpkgs/master;
    sops-nix.url = github:Mic92/sops-nix;
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix, ... }:
    let
      overlays = [ (import ./pkgs/overlay) ];
    in
    {
      nixosConfigurations = {
        x1 = let system = "x86_64-linux"; in
          nixpkgs.lib.nixosSystem {
            inherit system;
            pkgs = import nixpkgs {
              inherit system overlays;
              config.allowUnfree = true;
            };
            modules = [
              ./common.nix
              ./x1/configuration.nix
              sops-nix.nixosModules.sops
            ];
          };
        merovingian = let system = "x86_64-linux"; in
          nixpkgs.lib.nixosSystem {
            inherit system;
            pkgs = import nixpkgs {
              inherit system overlays;
            };
            modules = [
              ./common.nix
              ./merovingian/configuration.nix
              sops-nix.nixosModules.sops
            ];
          };
        #pajo = let system = "aarch64-linux"; in
        #  nixpkgs.lib.nixosSystem {
        #    inherit system;
        #    pkgs = import nixpkgs {
        #      inherit system overlays;
        #    };
        #    modules = [
        #      ./common.nix
        #      ./pajo/configuration.nix
        #      sops-nix.nixosModules.sops
        #    ];
        #  };
      };
    };
}
