{{- if or (eq .Values.mode "watchonly") (eq .Values.mode "complete") }}
{{/*
Expand the name of the chart.
*/}}
{{- define "lnd.watchonly.name" -}}
{{- default .Chart.Name .Values.watchonly.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lnd.watchonly.fullname" -}}
{{- if .Values.watchonly.fullnameOverride }}
{{- .Values.watchonly.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.watchonly.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "lnd.watchonly.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lnd.watchonly.labels" -}}
helm.sh/chart: {{ include "lnd.watchonly.chart" . }}
{{ include "lnd.watchonly.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lnd.watchonly.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lnd.watchonly.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lnd.watchonly.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lnd.watchonly.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "walletPassword" -}}

{{- $secret := (lookup "v1" "Secret" .Release.Namespace ( printf "%s-pass" (include "lnd.watchonly.fullname" .))) -}}
{{- if $secret -}}
{{/*
   Reusing current password since secret exists
*/}}
{{-  $secret.data.password -}}
{{- else -}}
{{/*
    Generate new password
*/}}
{{- (randAlpha 24) | b64enc -}}
{{- end -}}
{{- end -}}
{{- end }}