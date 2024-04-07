{
  description = "GDS to glTF files converter script";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    poetry2nix = {
      url = "github:nix-community/poetry2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, poetry2nix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        # see https://github.com/nix-community/poetry2nix/tree/master#api for more functions and examples.
        pkgs = nixpkgs.legacyPackages.${system};
        p2n = poetry2nix.lib.mkPoetry2Nix { inherit pkgs; };
      in
      {
        packages = {
          gds2gltf = p2n.mkPoetryApplication {
            projectDir = self;

            overrides = p2n.overrides.withDefaults (self: super: {

              marshmallow = super.marshmallow.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ self.flit-core ];
              });

              gdspy = super.gdspy.overridePythonAttrs (old: {
                buildInputs = (old.buildInputs or [ ]) ++ [ self.setuptools ];
              });

            });
          };
          default = self.packages.${system}.gds2gltf;
        };

        devShells.default = pkgs.mkShell {
          inputsFrom = [ self.packages.${system}.gds2gltf ];
          packages = [ pkgs.poetry ];
        };
      });
}
