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

[private]
@default:
    just --list

[doc('Generate the JSON schema based on values.yaml')]
[group('build')]
generate_schema:
    helm-schema --append-newline

[doc('Generate the CRDs for the current version of Traefik')]
[group('build')]
generate_crds: clean_crds
    #!/usr/bin/env bash
    version=$(yq eval '.appVersion' Chart.yaml)

    curl --silent --location "https://raw.githubusercontent.com/traefik/traefik/${version}/docs/content/reference/dynamic-configuration/kubernetes-crd-definition-v1.yml" |
        csplit --quiet --elide-empty-files --prefix=crds/ --suffix-format='%02d.yaml' - '/^---/' '{*}'

    for file in crds/*.yaml; do
        name=$(yq eval '.metadata.name | sub("\.", "") | "\(.)_'"${version}"'.yaml"' "${file}")
        mv "${file}" "crds/${name}"
    done

[doc('Remove the generated CRDs')]
[group('clean')]
clean_crds:
    rm --force crds/*

compile_examples example:
    @: {{ if example =~ 'examples/.+\.yaml$' {""} else { error("only YAML files in 'examples' are allowed") } }}
    @: {{ if path_exists(example) == "false" { error("file not found... aborted") } else {""} }}
    helm template {{ replace_regex(example, 'examples/(?<name>.+).yaml', '$name') }} . \
        --debug \
        --namespace default \
        --values {{ example }} \
        --output-dir validations/{{ replace_regex(example, 'examples/(?<name>.+).yaml', '$name') }}