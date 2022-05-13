{
  description = "zevson";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    let
      supportedSystems = [
        "aarch64-linux"
        "x86_64-linux"
      ];
    in
    flake-utils.lib.eachSystem supportedSystems (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
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
