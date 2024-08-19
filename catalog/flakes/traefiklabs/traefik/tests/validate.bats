#!/usr/bin/env bats
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
bats_require_minimum_version 1.11.0
bats_load_library bats-support
bats_load_library bats-assert
bats_load_library bats-docker

@test "traefik image runs properly." {
    container_setup --wait 30 ${TEST_APP_IMAGE} -- --ping
    assert_success

    container_run ${TEST_APP_IMAGE} healthcheck --ping
    assert_success
    assert_output "OK: http://:8080/ping"
}

@test "traefik image has the dashboard embedded." {
    container_setup --wait 30 ${TEST_APP_IMAGE} -- --ping --api.insecure --api.dashboard
    assert_success

    container_run curlimages/curl:8.9.1 \
        --silent --fail "http://localhost:8080/dashboard/"
    assert_success
    assert_output --partial "<title>Traefik</title>"
}
