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
{{- $ports := .ports -}}
{{- range $name, $spec := $ports }}
{{- if and (not ($spec.disabled | default false)) (has "ClusterIP" $spec.exposeAs) }}
- name: {{ $name }}
  port: {{ $spec.port }}
  targetPort: {{ $name }}
  protocol: {{ $spec.protocol | upper }}
{{- if hasKey $spec "appProtocol" }}
  appProtocol: {{ $spec.appProtocol }}
{{- end }}
{{- end }}
{{- end -}}
{{- end -}}

{{/* Generate a list of ports that must be defined into a LoadBalancer service */}}
{{- define "service.ports.loadBalancer" -}}
{{- $ports := .ports -}}
{{- range $name, $spec := $ports }}
{{- if and (not ($spec.disabled | default false)) (has "LoadBalancer" $spec.exposeAs) }}
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
{{- end -}}
{{- end -}}

{{/* Generate a list of ports that must be defined into a NodePort service */}}
{{- define "service.ports.nodePort" -}}
{{- $ports := .ports -}}
{{- range $name, $spec := $ports }}
{{- if and (not ($spec.disabled | default false)) (has "NodePort" $spec.exposeAs) }}
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
{{- end -}}
{{- end -}}
