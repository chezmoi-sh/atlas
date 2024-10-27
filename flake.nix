{
  description = "Atlas Nix configuration";

  # Nixpkgs / NixOS version to use.
  # inputs.nixpkgs.url = "nixpkgs/nixos-24.11";
  # TODO: nixos-24.11 is not currently available, and required to build some
  #       flake, so we will use this one too too avoid using two different
  #       nixpkgs versions and increasing the space usage.
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs =
    { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in
      rec {
        packages = {
          kubevault = pkgs.rustPlatform.buildRustPackage {
            pname = "kubevault";
            version = "1.1.0";
            src = pkgs.fetchFromGitHub {
              owner = "chezmoi-sh";
              repo = "kubevault";
              rev = "1.1.0";
              hash = "sha256-PLQusY/hiqy6GsEYsV2tQjUHckV/04o5mEaw6NLrZV8=";
            };

            cargoHash = "sha256-N85XU02MtkCm7zbvSA1Tv5VkKciJQM1Fwwb3F0vIOiU=";
          };
        };

        devShells.default = pkgs.mkShell {
          packages = [
            packages.kubevault
            pkgs.bashInteractive
            pkgs.bats
            pkgs.commitlint
            pkgs.d2
            pkgs.delta
            pkgs.devcontainer
            pkgs.dive
            pkgs.docker-client
            pkgs.fzf
            pkgs.gum
            pkgs.kubernetes-helm
            pkgs.helm-docs
            pkgs.just
            pkgs.k3d
            pkgs.k9s
            pkgs.kubectl
            pkgs.lefthook
            pkgs.nil
            pkgs.nix-output-monitor
            pkgs.nixfmt-rfc-style
            pkgs.tilt
            pkgs.trunk-io
            pkgs.localstack
            pkgs.awscli
            pkgs.fzf
            pkgs.yq-go
            pkgs.sops
            pkgs.age
            pkgs.lazygit
          ];

          env = {
            BATS_ROOT = "${pkgs.bats}";
            BATS_LIB_PATH = "${pkgs.bats.libraries.bats-assert}/share/bats:${pkgs.bats.libraries.bats-support}/share/bats:${pkgs.bats.libraries.bats-file}/share/bats";
          };

          installPhase = "";
        };
      }
    );
}
