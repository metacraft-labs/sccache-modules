{
  description = "MetaCraft Labs NixOS modules";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
      perSystem = {
        config,
        pkgs,
        self',
        inputs,
        system,
        ...
      }: {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [figlet];
          shellHook = ''
            figlet -w 80 "MCL's NixOS Modules"
          '';
        };
        nixosConfigurations.sccache = inputs.nixpkgs.lib.nixosSystem {
          inherit pkgs system;
          modules = [./modules/sccache.nix];
          specialArgs = {
            user = "monyarm";
            nixpkgs = inputs.nixpkgs;
          };
        };
      };
    };
}
