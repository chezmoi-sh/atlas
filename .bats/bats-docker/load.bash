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
# bats-docker - Common tools for testing Docker images with Bats
#
# shellcheck disable=1090
source "$(dirname "${BASH_SOURCE[0]}")/src/build_image_with_nix.bash"
source "$(dirname "${BASH_SOURCE[0]}")/src/container_run.bash"
source "$(dirname "${BASH_SOURCE[0]}")/src/container_setup.bash"
source "$(dirname "${BASH_SOURCE[0]}")/src/container_teardown.bash"
source "$(dirname "${BASH_SOURCE[0]}")/src/copy_to_volume.bash"
