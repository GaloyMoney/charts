FROM lncm/bitcoind:v24.0.1

USER root

RUN apk add curl python3

USER bitcoind

RUN cd ~ && \
  curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-359.0.0-linux-x86_64.tar.gz \
  && tar -xvzf ./google-cloud* \
  && ./google-cloud-sdk/install.sh --quiet \
  && rm *.tar.gz

ENV PATH="${PATH}:/data/google-cloud-sdk/bin"

ENTRYPOINT []
