{{- define "service.port.rpc" }}
{{- if eq .Values.global.network "mainnet" -}}
8332
{{- end -}}
{{- if eq .Values.global.network "testnet" -}}
18332
{{- end -}}
{{- if eq .Values.global.network "regtest" -}}
18443
{{- end -}}
{{- end -}}

{{- define "service.port.p2p" }}
{{- if eq .Values.global.network "mainnet" -}}
8333
{{- end -}}
{{- if eq .Values.global.network "testnet" -}}
18333
{{- end -}}
{{- if eq .Values.global.network "regtest" -}}
18444
{{- end -}}
{{- end }}


{{- define "bitcoindCustomConfig" }}
{{- if eq .Values.global.network "mainnet" -}}
bitcoindCustomConfig:
- dbcache=3600
- bind=0.0.0.0
- rpcbind=0.0.0.0
- rpcallowip=0.0.0.0/0
{{- end -}}
{{- end }}
{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "bitcoind.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "bitcoind.fullname" -}}
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
Create chart name and version as used by the chart label.
*/}}
{{- define "bitcoind.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "bitcoind.labels" -}}
helm.sh/chart: {{ include "bitcoind.chart" . }}
{{ include "bitcoind.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "bitcoind.selectorLabels" -}}
app.kubernetes.io/name: {{ include "bitcoind.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "bitcoind.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "bitcoind.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
