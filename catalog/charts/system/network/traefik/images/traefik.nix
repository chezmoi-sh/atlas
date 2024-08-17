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
{ pkgs, ... }:

let
  # renovate: datasource=github-tags depName=traefik/traefik
  version = "3.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "traefik";
    repo = "traefik";
    rev = "v${version}";
    hash = "sha256-PuaRRng8mdhwtyX4MrYcZQgkcnSj7n/AT3Vf+zEJz04=";
  };
in
rec {
  inherit version;

  # ┌───────────────────────────────────────────────────────────────────────────┐
  # │ <traefik-webui>: Build the Traefik web UI from source using Yarn.         │
  # └───────────────────────────────────────────────────────────────────────────┘
  traefik-webui = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "traefik-webui";
    inherit version;

    src = "${src}/webui";

    offlineCache = pkgs.fetchYarnDeps {
      yarnLock = "${finalAttrs.src}/yarn.lock";
      hash = "sha256-NBDSURA7UDxIbFqvMm7cMFBkh2Nfp5af02P9qq7HKB4=";
    };

    nativeBuildInputs = [
      pkgs.yarnConfigHook
      pkgs.yarnBuildHook
      pkgs.nodejs
      pkgs.npmHooks.npmInstallHook
    ];

    installPhase = ''
      cp --preserve=all --no-dereference --recursive static $out
    '';
  });

  # ┌───────────────────────────────────────────────────────────────────────────┐
  # │ <traefik>: Build the Traefik image from source using Go.                  │
  # └───────────────────────────────────────────────────────────────────────────┘
  traefik =
    let
      # get some Traefik metadata required to build the image
      codeName =
        let
          codeName = builtins.match ".*CODENAME \\?=[[:space:]]([a-z0-9_-]+).*" (
            builtins.readFile "${src}/Makefile"
          );
        in
        if codeName == null then "unknown" else (builtins.elemAt codeName 0);
    in
    pkgs.buildGoModule {
      pname = "traefik";
      inherit version;

      src = pkgs.stdenv.mkDerivation {
        name = "source-with-assets";
        phases = [ "unpackPhase" ];

        srcs = [
          src
          traefik-webui
        ];
        sourceRoot = "${src.name}";

        # Copy the built web UI into the Traefik source tree.
        postUnpack = ''
          cp --preserve=all --no-dereference --recursive ${src.name} $out
          cp --preserve=all --no-dereference --recursive ${traefik-webui}/. $out/webui/static
        '';
      };

      vendorHash = "sha256-xQPDlwu/mRdyvZW0qSCA9eko9pOQAMwh2vVJWzMnyfs=";
      subPackages = [ "cmd/traefik" ];

      CGO_ENABLED = 0;
      ldflags = [
        "-s"
        "-w"
        "-X github.com/traefik/traefik/v${pkgs.lib.versions.major version}/pkg/version.Version=${version}"
        "-X github.com/traefik/traefik/v${pkgs.lib.versions.major version}/pkg/version.Codename=${codeName}"
      ];

      preBuild = ''
        GOOS= GOARCH= CGO_ENABLED=0 go generate
      '';
      doCheck = false;
    };
}
