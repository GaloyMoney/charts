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

{{- define "admin-panel.fullname" -}}
{{- $name := default "admin-panel" (index .Values "admin-panel").nameOverride -}}
{{- if .Values.fullnameOverride -}}
{{- printf "%s-%s" .Values.fullnameOverride $name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
