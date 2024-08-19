# Copyright (C) 2024 Alexandre Nicolaie (xunleii@users.noreply.github.com)
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# ----------------------------------------------------------------------------
# sh.chezmoi.app.image: traefik
# sh.chezmoi.app.type: helm
{
  description = "Traefik is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease.";

  # Nixpkgs / NixOS version to use.
  # inputs.nixpkgs.url = "nixpkgs/nixos-24.11";
  # TODO: nixos-24.11 is not currently available, and required for the yarn*Hook packages.
  inputs.nixpkgs.url = "nixpkgs/nixos-unstable";

  inputs.systems.url = "github:nix-systems/default";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  inputs.flake-utils.inputs.systems.follows = "systems";

  outputs =
    { self
    , nixpkgs
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system: {
      packages =
        let
          pkgs = import nixpkgs { inherit system; };
          inherit (import ./traefik.nix { inherit pkgs; }) traefik traefik-webui version;
        in
        rec {
          inherit traefik traefik-webui;

          # ┌───────────────────────────────────────────────────────────────────────────┐
          # │ <default>: Build the Traefik image based on the Traefik source code.      │
          # │            See `traefik.nix` for more details.                            │
          # └───────────────────────────────────────────────────────────────────────────┘
          default = pkgs.dockerTools.buildLayeredImage {
            name = "traefik";
            tag = "${version}-${pkgs.lib.versions.major pkgs.lib.version}.${pkgs.lib.versions.minor pkgs.lib.version}";

            # Add CA certificates that can be required by Traefik.
            contents = [
              pkgs.cacert
              pkgs.iana-etc
            ];

            config.Env = [ "TZDIR=${pkgs.tzdata}/share/zoneinfo" ];
            config.Entrypoint = [ "${traefik}/bin/traefik" ];
            config.Healthcheck = {
              Test = [
                "CMD"
                "${traefik}/bin/traefik"
                "healthcheck"
                "--ping"
              ];
              Interval = 10000000000; # 10s in nanoseconds
              Timeout = 2000000000; # 2s in nanoseconds
              Retries = 3;
              StartInterval = 15000000000; # 15s in nanoseconds
            };

            created = builtins.substring 0 8 self.lastModifiedDate;
            config.Labels = {
              "org.opencontainers.image.authors" = "chezmoi.sh Lab <xunleii@users.noreply.github.com>";
              "org.opencontainers.image.description" = "Traefik is a modern HTTP reverse proxy and load balancer made to deploy microservices with ease.";
              "org.opencontainers.image.documentation" = "https://doc.traefik.io";
              "org.opencontainers.image.licenses" = "Apache-2.0";
              "org.opencontainers.image.revision" = "v${version}";
              "org.opencontainers.image.source" = "https://github.com/chezmoi-sh/atlas/blob/main/catalog/charts/system/network/traefik/images/traefik/flake.nix";
              "org.opencontainers.image.title" = "traefik";
              "org.opencontainers.image.url" = "https://github.com/chezmoi-sh/atlas";
              "org.opencontainers.image.version" = "${version}";

              "sh.chezmoi.catalog.build.engine.type" = "nix";
              "sh.chezmoi.catalog.build.engine.version" = "${pkgs.lib.version}";
              "sh.chezmoi.catalog.category" = "system/network";
              "sh.chezmoi.catalog.origin.author" = "Traefik Labs <https://traefik.io>";
              "sh.chezmoi.catalog.origin.license" = "MIT";
              "sh.chezmoi.catalog.origin.repository" = "github.com/traefik/traefik";
            };
            config.User = "44782:22760"; # NOTE: random UID/GID
          };
        };
    });
}
