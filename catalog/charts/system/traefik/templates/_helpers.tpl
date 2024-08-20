{{/*
Common helpers template
- release.name: Returns the name that should be used for all resources.
- release.selector.labels: Returns the common set of labels to be used as selector for services and workloads
- release.labels: Returns the common set of labels to be added to all resources
*/}}
{{- define "release.name" -}}
{{- printf "%s-%s" .Chart.Name .Release.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "release.selector.labels" -}}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}

{{- define "release.labels" -}}
app.kubernetes.io/name: {{ include "release.name" . }}
{{ include "release.selector.labels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- with .Values.metadata.labels -}}
{{ toYaml . }}
{{- end }}
{{- end }}

{{/* Prefix all role with the same prefix: <chart>:<namespace>-<release>: */}}
{{- define "rbac.role.prefix" -}}
{{ printf "%s:%s-%s" .Chart.Name .Release.Namespace .Release.Name | trunc 46 | trimSuffix "-" }}
{{- end -}}