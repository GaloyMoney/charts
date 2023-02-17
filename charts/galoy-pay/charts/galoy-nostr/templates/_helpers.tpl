{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "galoyNostr.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Return Galoy environment variables for Redis configuration
*/}}
{{- define "galoyNostr.redis.env" -}}
- name: REDIS_MASTER_NAME
  value: {{ .Values.redis.sentinel.masterSet | quote }}
- name: REDIS_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.redis.auth.existingSecret | quote }}
      key: {{ .Values.redis.auth.existingSecretPasswordKey | quote }}
{{ range until (.Values.redis.replica.replicaCount | int) }}
- name: {{ printf "REDIS_%d_DNS" . }}
  value: {{ printf "galoy-nostr-redis-node-%d.galoy-nostr-redis-headless" . | quote }}
{{ end }}
{{- end -}}
