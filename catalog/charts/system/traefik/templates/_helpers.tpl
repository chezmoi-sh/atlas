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
{{- end }}

{{/* Generate a common set of labels to be added to all resources */}}
{{- define "release.labels" -}}
app.kubernetes.io/name: {{ include "release.name" . }}
{{ include "release.labels.selector" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
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

{{/*
  Traefik specific helpers for this chart.
*/}}

{{/* Generate args based on traefik configuration */}}
{{- define "traefik.args" -}}
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
{{ $key }}
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
