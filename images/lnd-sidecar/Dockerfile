FROM lightninglabs/lnd:v0.15.3-beta as lnd
FROM lightninglabs/loop:v0.20.1-beta as loop

FROM alpine/k8s:1.21.5

COPY --from=lnd /bin/lncli /bin/lncli
COPY --from=loop /bin/loop /bin/loop

RUN apk --update add expect curl jq

ENTRYPOINT []
