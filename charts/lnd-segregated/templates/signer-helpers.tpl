{{- if or (eq .Values.mode "signer") (eq .Values.mode "complete") }}
{{/*
Expand the name of the chart.
*/}}
{{- define "lnd.signer.name" -}}
{{- default .Chart.Name .Values.signer.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "lnd.signer.fullname" -}}
{{- if .Values.signer.fullnameOverride }}
{{- .Values.signer.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.signer.nameOverride }}
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
{{- define "lnd.signer.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "lnd.signer.labels" -}}
helm.sh/chart: {{ include "lnd.signer.chart" . }}
{{ include "lnd.signer.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "lnd.signer.selectorLabels" -}}
app.kubernetes.io/name: {{ include "lnd.signer.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "lnd.signer.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "lnd.signer.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "walletPassword" -}}

{{- $secret := (lookup "v1" "Secret" .Release.Namespace ( printf "%s-pass" (include "lnd.signer.fullname" .))) -}}
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