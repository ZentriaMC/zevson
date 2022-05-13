{
  description = "zevson";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    openzfs-osx-shim-nix.url = "github:mikroskeem/openzfs-osx-shim-nix";

    openzfs-osx-shim-nix.inputs.nixpkgs.follows = "nixpkgs";
    openzfs-osx-shim-nix.inputs.flake-utils.follows = "flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, openzfs-osx-shim-nix }:
    let
      supportedSystems = [
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            openzfs-osx-shim-nix.overlay
          ];
        };
      in
      rec {
        packages.zevson = pkgs.callPackage
          ({ stdenv, lib, pkg-config, zfs }: stdenv.mkDerivation {
            pname = "zevson";
            version = self.rev or "dirty";
            src = lib.cleanSource ./.;

            buildInputs = [
              zfs
            ];

            nativeBuildInputs = [
              pkg-config
            ];

            dontConfigure = true;

            makeFlags = [
              "DESTDIR=$(out)"
              "PREFIX="
            ];

            meta = with lib; { };
          })
          { };

        defaultPackage = packages.zevson;
      });
}
