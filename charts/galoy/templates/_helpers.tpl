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
Create a Service Account so that wait-for-mongodb-migrate task works properly, because it needs to do
kubectl get commands from the pod that requires higher permissions than default service account.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "galoy.serviceAccountName" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-sa" $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
