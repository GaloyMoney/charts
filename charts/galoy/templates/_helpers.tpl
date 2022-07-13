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

{{/*
Return Galoy environment variables for network
*/}}
{{- define "galoy.network.env" -}}
- name: NETWORK
  value: {{ .Values.galoy.network }}
{{- end -}}

{{/*
Return Galoy environment variables for BitcoinD configuration
*/}}
{{- define "galoy.bitcoind.env" -}}
- name: BITCOINDADDR
  value: {{ .Values.galoy.bitcoind.dns | quote }}
- name: BITCOINDPORT
  value: {{ .Values.galoy.bitcoind.port | quote }}
- name: BITCOINDRPCPASS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.bitcoind.rpcPasswordExistingSecret.name }}
      key: {{ .Values.galoy.bitcoind.rpcPasswordExistingSecret.key }}
{{- end -}}

{{/*
Return Galoy environment variables for LND 1 configuration
*/}}
{{- define "galoy.lnd1.env" -}}
- name: LND1_DNS
  value: {{ .Values.galoy.lnd1.dns | quote }}
- name: LND1_MACAROON
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.lnd1.credentialsExistingSecret.name }}
      key: {{ .Values.galoy.lnd1.credentialsExistingSecret.macaroon_key }}
- name: LND1_TLS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.lnd1.credentialsExistingSecret.name }}
      key: {{ .Values.galoy.lnd1.credentialsExistingSecret.tls_key }}
- name: LND1_PUBKEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.lnd1.pubkeyExistingSecret.name }}
      key: {{ .Values.galoy.lnd1.pubkeyExistingSecret.key }}
{{- end -}}

{{/*
Return Galoy environment variables for LND 2 configuration
*/}}
{{- define "galoy.lnd2.env" -}}
- name: LND2_DNS
  value: {{ .Values.galoy.lnd2.dns | quote }}
- name: LND2_MACAROON
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.lnd2.credentialsExistingSecret.name }}
      key: {{ .Values.galoy.lnd2.credentialsExistingSecret.macaroon_key }}
- name: LND2_TLS
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.lnd2.credentialsExistingSecret.name }}
      key: {{ .Values.galoy.lnd2.credentialsExistingSecret.tls_key }}
- name: LND2_PUBKEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.lnd2.pubkeyExistingSecret.name }}
      key: {{ .Values.galoy.lnd2.pubkeyExistingSecret.key }}
{{- end -}}

{{/*
Return Galoy environment variables for Geetest configuration
*/}}
{{- define "galoy.geetest.env" -}}
- name: GEETEST_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.api.geetestExistingSecret.name }}
      key: {{ .Values.galoy.api.geetestExistingSecret.id_key }}
- name: GEETEST_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.api.geetestExistingSecret.name }}
      key: {{ .Values.galoy.api.geetestExistingSecret.secret_key }}
{{- end -}}

{{/*
Return Galoy environment variables for Redis configuration
*/}}
{{- define "galoy.redis.env" -}}
- name: REDIS_MASTER_NAME
  value: {{ .Values.redis.sentinel.masterSet }}
- name: REDIS_PASSWORD
  value: {{ .Values.redis.auth.password }}
{{ range until (.Values.redis.replica.replicaCount | int) }}
- name: {{ printf "REDIS_%d_DNS" . }}
  value: {{ printf "galoy-redis-node-%d.galoy-redis-headless" . | quote }}
{{ end }}
{{- end -}}

{{/*
Return Galoy environment variables for JWT Secret
*/}}
{{- define "galoy.jwt.env" -}}
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.api.jwtSecretExistingSecret.name }}
      key: {{ .Values.galoy.api.jwtSecretExistingSecret.key }}
{{- end -}}
