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

nix_output_monitor_path := shell("command -v nom")
nix_cmd := if nix_output_monitor_path != "" { "nom" } else { "nix" }
bats_format := if env("CI", "···") == "···" { "pretty" } else { "junit" }

[private]
@default:
    just --list

[doc('Display information about the flake')]
info:
    @nix flake metadata
    @echo
    @nix flake show

[doc('Build the container image base on the flake definition')]
[group('build')]
build:
    @export TMPDIR=/nix/tmp
    {{nix_cmd}} build


[doc('Run all compliance tests')]
[group('test')]
test-compliance: build
    bats --formatter {{bats_format}} --timing --print-output-on-failure tests --filter-tags 'docker:compliance'

[doc('Run all validation tests')]
[group('test')]
test-validation: build
    bats --formatter {{bats_format}} --timing --print-output-on-failure tests --filter-tags '!docker:compliance'

[doc('Run all tests')]
[group('test')]
test: test-compliance test-validation
