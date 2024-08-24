{{/*
  Traefik specific helpers for this chart.
*/}}

{{/* Generate args based on traefik configuration */}}
{{- define "traefik.args" -}}
{{- range $key, $value := . }}
  {{- include "traefik.args.rec" (list (printf "- --%s" $key) $value) }}
{{- end -}}
{{- end -}}

{{- define "traefik.args.rec" -}}
{{- $key := index . 0 }}
{{- $value := index . 1 }}

{{- if typeIs "map[string]interface {}" $value }}
  {{- if eq (len $value) 0 }}
{{ $key }}
  {{- else }}
    {{- include "traefik.args.object" (list $key $value) }}
  {{- end }}
{{- else if typeIs "[]interface {}" $value }}
  {{- range $index, $item := $value }}
    {{- include "traefik.args.rec" (list (printf "%s[%d]" $key $index) $item) }}
  {{- end -}}
{{- else if (eq $value nil) }}
{{- else if typeIs "string" $value }}
{{ $key }}={{ $value | quote }}
{{- else }}
{{ $key }}={{ $value }}
{{- end }}
{{- end -}}

{{- define "traefik.args.object" -}}
{{- $prefix := index . 0 }}
{{- $object := index . 1 }}
{{- range $key, $value := $object }}
  {{- include "traefik.args.rec" (list (printf "%s.%s" $prefix $key) $value) }}
{{- end -}}
{{- end -}}

{{/* Generate container ports based on entrypoint */}}
{{- define "traefik.container.ports" -}}
{{- $entrypoints := .entryPoints -}}
{{- range $name, $spec := $entrypoints }}
{{- if not (hasKey $spec "address") }}
{{- fail (printf "spec.traefik.entryPoints.%s.address is required" $name) }}
{{- end }}
{{- $address := get $spec "address" }}
{{- if not (regexMatch "^(?:[^:]+)?:\\d+(?:/(?:udp|tcp))?$" (trim $address)) }}
{{- fail (printf "spec.traefik.entryPoints.%s.address is invalid: expected '[host]:port[/tcp|/udp]' but got '%s'" $name $address) }}
{{- end }}
{{- $port := regexReplaceAll "^(?:[^:]+)?:(\\d+)(?:/(?:udp|tcp))?$" $address "${1}" }}
{{- $protocol := regexReplaceAll "^(?:[^:]+)?:\\d+(/(udp|tcp))?$" $address "${2}" | lower | default "tcp" }}
- name: {{ $name }}
  containerPort: {{ $port }}
  protocol: {{ $protocol }}
{{- end -}}
{{- end -}}
