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
# trunk-ignore-all(shellcheck/SC2292): https://bats-core.readthedocs.io/en/stable/gotchas.html#or-did-not-fail-my-test
bats_require_minimum_version 1.11.0
bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-file

# setup_suite
# ===========
#
# Summary: Build the container image and load it into the Docker daemon.
setup_suite() {
	export BATS_TEST_TMPDIR=$(mktemp -d) # trunk-ignore(shellcheck/SC2155)
	export BATS_TEST_TIMEOUT=300         # timeout after 30 seconds

	# preflight checks to ensure that the environment is ready
	assert_file_exists "flake.nix"
	run grep -oP '(?<=^# sh.chezmoi.app.image: )[^ ]+' flake.nix
	[[ ${status} -ne 0 || -z ${output} ]] && fail 'The `sh.chezmoi.app.image` attribute (comment) is not set in `flake.nix`.' # trunk-ignore(shellcheck/SC2016)
	export TEST_APP_NAME="${output}"

	# build the container image using Nix
	mkdir --parents /nix/tmp
	TMPDIR=/nix/tmp run nix build --print-out-paths
	assert_success

	# load the container image into the Docker daemon and retag it
	# for the test suite
	run docker load <"${lines[-1]}"
	assert_success

	local -r __docker_load_output="${lines[-1]}"
	run grep -oP '(?<=Loaded image: )[^ ]*' <<<"${__docker_load_output}"
	if [ -z "${output}" ]; then
		run grep -oP '(?<=The image )[^ ]*' <<<"${__docker_load_output}"
	fi
	local -r __docker_image_name="${output}"

	run bash -c "LC_ALL=C tr -dc 'a-z' </dev/urandom | head -c 16"
	assert_success

	export TEST_APP_IMAGE="${__docker_image_name%%:*}:bats-${output}"
	run docker tag "${__docker_image_name}" "${TEST_APP_IMAGE}"
	assert_success
}

# teardown_suite
# ==============
#
# Summary: Remove the container image from the Docker daemon.
teardown_suite() {
	run docker image rm --force "${TEST_APP_IMAGE}"
}
