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
# trunk-ignore-all(shellcheck/SC2312)

# container_teardown
# ===========
#
# Summary: Stop the container then remove it.
#
# Usage: container_teardown [<container_name>]
#
# Options:
#   <container_name>  The name or id of the container to stop and remove (default: $TEST_CONTAINER_ID)
#
# Globals:
#   output
#   lines
# Returns:
#   0 - container stopped and removed
#   1 - otherwise
function container_teardown() {
	local -r container_id="${1:-${TEST_CONTAINER_ID}}"
	[[ -z ${container_id} ]] && return 0 # nothing to do if no container id is set

	run docker container inspect "${container_id}" >/dev/null 2>&1
	if [[ ${status} -ne 0 ]]; then
		batslib_print_kv_single 0 'container_id' "${container_id}" |
			batslib_decorate "container not found" |
			fail
	fi

	run docker container rm --force "${container_id}"
	assert_success
}
