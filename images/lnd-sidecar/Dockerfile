FROM lightninglabs/lnd:v0.18.5-beta as lnd

FROM alpine/k8s:1.23.14

COPY --from=lnd /bin/lncli /bin/lncli

RUN apk --update add expect curl jq

ENTRYPOINT []
