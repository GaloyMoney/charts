{{- define "bitcoind.port.rpc" }}
{{- if eq .Values.global.network "mainnet" -}}
8332
{{- end -}}
{{- if eq .Values.global.network "testnet" -}}
18332
{{- end -}}
{{- if eq .Values.global.network "regtest" -}}
18443
{{- end -}}
{{- end }}


{{- define "bitcoind.port.p2p" }}
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
