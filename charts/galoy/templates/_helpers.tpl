{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "galoy.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified api name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "galoy.api.fullname" -}}
{{- $name := default "api" .Values.galoy.api.nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Migration Job name
*/}}
{{- define "galoy.migration.jobname" -}}
{{- printf "%s-mongodb-migrate-%s" .Release.Name .Release.Revision -}}
{{- end -}}

{{/*
Pre-Migration Job name
*/}}
{{- define "galoy.pre-migration.jobname" -}}
{{- printf "%s-pre-mongodb-migrate-%s" .Release.Name .Release.Revision -}}
{{- end -}}

{{/*
Return Galoy environment variables for MongoDB configuration
*/}}
{{- define "galoy.mongodb.env" -}}
- name: MONGODB_ADDRESS
  value: "{{ range until (.Values.mongodb.replicaCount | int) }}
  {{- printf "galoy-mongodb-%d.galoy-mongodb-headless" . -}}
  {{- if lt . (sub $.Values.mongodb.replicaCount 1 | int) -}},{{- end -}}
  {{ end }}"
- name: MONGODB_USER
  value: {{ index .Values.mongodb.auth.usernames 0 | quote }}
- name: MONGODB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mongodb.auth.existingSecret }}
      key: mongodb-password
{{- end -}}
