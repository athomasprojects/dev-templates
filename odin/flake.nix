{
  description = "A Nix-flake-based Odin development environment";
  # builds a shell with the latest Odin compiler release

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    odin-overlay.url = "github:kilzm/odin-overlay";
    odin-overlay.flake = true;
  };

  outputs = {
    self,
    nixpkgs,
    odin-overlay,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {
            inherit system;
            overlays = [odin-overlay.overlays.default];
            config = {
              allowUnfree = true;
            };
          };
        });
  in {
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        name = "odin-shell";

        nativeBuildInputs = with pkgs.odin-pkgs; [
          odin-latest
        ];
      };
    });
  };
}
