{
  description = "NixOS — Sway setup";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs-unstable = import nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    nixosConfigurations.nixos-btw = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./configuration.nix
        (if builtins.pathExists ./secrets.nix then ./secrets.nix else {})
        home-manager.nixosModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.johncarlojose = import ./home.nix;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit pkgs-unstable; };
          };
        }
      ];
    };
  };
}