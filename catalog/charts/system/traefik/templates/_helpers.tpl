{{/*
  Common template helpers that are used by any charts.
*/}}

{{/* Prefix all role with the same prefix: <chart>:<namespace>-<release>: */}}
{{- define "rbac.role.prefix" -}}
{{ printf "%s:%s-%s" .Chart.Name .Release.Namespace .Release.Name | trunc 46 | trimSuffix "-" }}
{{- end }}

{{/* Generate a "generic" name to use everywhere based on the chart name and release name */}}
{{- define "release.name" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Generate a common set of labels to be used as selector for services and workloads */}}
{{- define "release.labels.selector" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/* Generate a common set of labels to be added to all resources */}}
{{- define "release.labels" -}}
app.kubernetes.io/name: {{ include "release.name" . }}
{{ include "release.labels.selector" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- with (.Values.metadata).labels }}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/* Generate a common set of annotations to be added to all resources */}}
{{- define "release.annotations" -}}
{{- with (.Values.metadata).annotations -}}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/* Generate a list of ports that must be defined into a Cluster IP service */}}
{{- define "service.ports.clusterIP" -}}
{{- include "service.ports.clusterIP.untrimmed" . | trim -}}
{{- end -}}

{{- define "service.ports.clusterIP.untrimmed" -}}
{{- $ports := .ports -}}
{{- range $name, $spec := $ports -}}
{{- if and (not ($spec.disabled | default false)) (has "ClusterIP" $spec.exposeAs) -}}
- name: {{ $name }}
  port: {{ $spec.port }}
  targetPort: {{ $name }}
  protocol: {{ $spec.protocol | upper }}
{{- if hasKey $spec "appProtocol" }}
  appProtocol: {{ $spec.appProtocol }}
{{- end }}
{{- end }}
{{ end -}}
{{- end -}}

{{/* Generate a list of ports that must be defined into a LoadBalancer service */}}
{{- define "service.ports.loadBalancer" -}}
{{- include "service.ports.loadBalancer.untrimmed" . | trim -}}
{{- end -}}

{{- define "service.ports.loadBalancer.untrimmed" -}}
{{- $ports := .ports -}}
{{- range $name, $spec := $ports -}}
{{- if and (not ($spec.disabled | default false)) (has "LoadBalancer" $spec.exposeAs) -}}
- name: {{ $name }}
  port: {{ $spec.port }}
{{- if hasKey $spec "nodePort" }}
  nodePort: {{ $spec.nodePort }}
{{- end }}
  targetPort: {{ $name }}
  protocol: {{ $spec.protocol | upper }}
{{- if hasKey $spec "appProtocol" }}
  appProtocol: {{ $spec.appProtocol }}
{{- end }}
{{- end }}
{{ end -}}
{{- end -}}

{{/* Generate a list of ports that must be defined into a NodePort service */}}
{{- define "service.ports.nodePort" -}}
{{- include "service.ports.nodePort.untrimmed" . | trim -}}
{{- end -}}

{{- define "service.ports.nodePort.untrimmed" -}}
{{- $ports := .ports -}}
{{- range $name, $spec := $ports -}}
{{- if and (not ($spec.disabled | default false)) (has "NodePort" $spec.exposeAs) -}}
- name: {{ $name }}
  port: {{ $spec.port }}
{{- if hasKey $spec "nodePort" }}
  nodePort: {{ $spec.nodePort }}
{{- end }}
  targetPort: {{ $name }}
  protocol: {{ $spec.protocol | upper }}
{{- if hasKey $spec "appProtocol" }}
  appProtocol: {{ $spec.appProtocol }}
{{- end }}
{{- end }}
{{ end -}}
{{- end -}}


{{/*
  Traefik specific helpers for this chart.
*/}}

{{/* Generate args based on traefik configuration */}}
{{- define "traefik.args" -}}
{{- include "traefik.args.untrimmed" . | trim -}}
{{- end -}}

{{- define "traefik.args.untrimmed" -}}
{{- range $key, $value := . -}}
  {{- include "traefik.args.rec" (list (printf "- --%s" $key) $value) | trim }}
{{ end -}}
{{- end -}}

{{- define "traefik.args.rec" -}}
{{- $key := index . 0 -}}
{{- $value := index . 1 -}}
{{- if typeIs "map[string]interface {}" $value -}}
  {{- if eq (len $value) 0 -}}
{{ $key }}
  {{- else -}}
    {{- include "traefik.args.object" (list $key $value) }}
  {{- end -}}
{{- else if typeIs "[]interface {}" $value -}}
  {{- range $index, $item := $value -}}
    {{- include "traefik.args.rec" (list (printf "%s[%d]" $key $index) $item) | trim}}
{{ end -}}
{{- else if (eq $value nil) -}}
{{- else if typeIs "string" $value -}}
{{ $key }}={{ $value | quote }}
{{- else -}}
{{ $key }}={{ $value }}
{{- end -}}
{{- end -}}

{{- define "traefik.args.object" -}}
{{- $prefix := index . 0 -}}
{{- $object := index . 1 -}}
{{- range $key, $value := $object -}}
  {{- include "traefik.args.rec" (list (printf "%s.%s" $prefix $key) $value) | trim }}
{{ end -}}
{{- end -}}

{{/* Generate container ports based on entrypoint */}}
{{- define "traefik.container.ports" -}}
{{- include "traefik.container.ports.untrimmed" . | trim -}}
{{- end -}}

{{- define "traefik.container.ports.untrimmed" -}}
{{- $entrypoints := .entryPoints -}}
{{- range $name, $spec := $entrypoints -}}
{{- if not (hasKey $spec "address") -}}
{{- fail (printf "spec.traefik.entryPoints.%s.address is required" $name) -}}
{{- end -}}
{{- $address := get $spec "address" -}}
{{- if not (regexMatch "^(?:[^:]+)?:\\d+(?:/(?:udp|tcp))?$" (trim $address)) -}}
{{- fail (printf "spec.traefik.entryPoints.%s.address is invalid: expected '[host]:port[/tcp|/udp]' but got '%s'" $name $address) -}}
{{- end -}}
{{- $port := regexReplaceAll "^(?:[^:]+)?:(\\d+)(?:/(?:udp|tcp))?$" $address "${1}" -}}
{{- $protocol := regexReplaceAll "^(?:[^:]+)?:\\d+(/(udp|tcp))?$" $address "${2}" | lower | default "tcp" -}}
- name: {{ $name }}
  containerPort: {{ $port }}
  protocol: {{ $protocol }}
{{ end -}}
{{- end -}}
