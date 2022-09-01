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
Create a default fully qualified admin name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "galoy.admin.fullname" -}}
{{- $name := default "admin" .Values.galoy.admin.nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified exporter name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "galoy.exporter.fullname" -}}
{{- $name := default "exporter" .Values.galoy.exporter.nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/*
Create a default fully qualified trigger name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "galoy.trigger.fullname" -}}
{{- $name := default "trigger" .Values.galoy.trigger.nameOverride -}}
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
{{- printf "%s-mongodb-migrate-%d" .Release.Name .Release.Revision -}}
{{- end -}}

{{/*
Pre-Migration Job name
*/}}
{{- define "galoy.pre-migration.jobname" -}}
{{- printf "%s-pre-mongodb-migrate-%d" .Release.Name .Release.Revision -}}
{{- end -}}

{{/*
Return Galoy environment variables for MongoDB configuration
*/}}
{{- define "galoy.mongodb.env" -}}
{{ if eq .Values.mongodb.architecture "replicaset" }}
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
      key: mongodb-passwords
{{ else if eq .Values.mongodb.architecture "standalone" }}
- name: MONGODB_ADDRESS
  value: "galoy-mongodb"
- name: MONGODB_USER
  value: {{ index .Values.mongodb.auth.usernames 0 | quote }}
- name: MONGODB_PASSWORD
  valueFrom:
    secretKeyRef:
      name: {{ .Values.mongodb.auth.existingSecret }}
      key: mongodb-passwords
{{ end }}
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
Return Galoy environment variables for Redis configuration
*/}}
{{- define "galoy.redis.env" -}}
- name: REDIS_MASTER_NAME
  value: {{ .Values.redis.sentinel.masterSet | quote }}
- name: REDIS_PASSWORD
  value: {{ .Values.redis.auth.password | quote }}
{{ range until (.Values.redis.replica.replicaCount | int) }}
- name: {{ printf "REDIS_%d_DNS" . }}
  value: {{ printf "galoy-redis-node-%d.galoy-redis-headless" . | quote }}
{{ end }}
{{- end -}}

{{/*
Return Galoy environment variables for Reporting to Apollo
*/}}
{{- define "galoy.apollo.env" -}}
- name: APOLLO_GRAPH_VARIANT
  value: {{ .Values.galoy.api.apollo.graphVariant | quote }}
- name: APOLLO_SCHEMA_REPORTING
  value: {{ .Values.galoy.api.apollo.schemaReporting | quote }}
- name: APOLLO_GRAPH_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.api.apollo.existingSecret.name }}
      key: {{ .Values.galoy.api.apollo.existingSecret.id_key }}
- name: APOLLO_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.api.apollo.existingSecret.name }}
      key: {{ .Values.galoy.api.apollo.existingSecret.key_key }}
{{- end -}}

{{/*
Return Galoy environment variables for Twilio
*/}}
{{- define "galoy.twilio.env" -}}
- name: TWILIO_PHONE_NUMBER
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.twilioExistingSecret.name }}
      key: {{ .Values.galoy.twilioExistingSecret.phone_number_key }}
- name: TWILIO_ACCOUNT_SID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.twilioExistingSecret.name }}
      key: {{ .Values.galoy.twilioExistingSecret.account_sid_key }}
- name: TWILIO_AUTH_TOKEN
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.twilioExistingSecret.name }}
      key: {{ .Values.galoy.twilioExistingSecret.auth_token_key }}
{{- end -}}

{{/*
Return Galoy environment variables for Geetest
*/}}
{{- define "galoy.geetest.env" -}}
- name: GEETEST_ID
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.geetestExistingSecret.name }}
      key: {{ .Values.galoy.geetestExistingSecret.id_key }}
- name: GEETEST_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.geetestExistingSecret.name }}
      key: {{ .Values.galoy.geetestExistingSecret.secret_key }}
{{- end -}}

{{/*
Return Galoy environment variables for JWT Secret
*/}}
{{- define "galoy.jwt.env" -}}
- name: JWT_SECRET
  valueFrom:
    secretKeyRef:
      name: {{ .Values.galoy.jwtSecretExistingSecret.name }}
      key: {{ .Values.galoy.jwtSecretExistingSecret.key }}
{{- end -}}

{{- define "galoy.jwtSecret" -}}
{{- $secret := (lookup "v1" "Secret" .Release.Namespace "jwt-secret") -}}
{{- if $secret -}}
{{/*
   Reusing current password since secret exists
*/}}
{{- $secret.data.secret -}}
{{- else if .Values.jwtSecret -}}
{{ .Values.jwtSecret | b64enc }}
{{- else -}}
{{/*
    Generate new password
*/}}
{{- (randAlpha 24) | b64enc -}}
{{- end -}}
{{- end -}}
