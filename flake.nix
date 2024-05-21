{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    rust-overlay,
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake = {
        overlays.default = nixpkgs.lib.composeManyExtensions [
          (import rust-overlay)
        ];
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {
        pkgs,
        system,
        ...
      }: {
        _module.args.pkgs = import inputs.nixpkgs {
          inherit system;
          overlays = [self.overlays.default];
        };

        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            fermyon-spin
            (rust-bin.stable.latest.default.override {
              targets = ["wasm32-wasi"];
            })
          ];
        };
      };
    };
}
