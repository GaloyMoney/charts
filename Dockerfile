FROM python:3.8-buster

RUN apt-get update \
  && apt-get install -y bash curl wget tar git gettext jq perl \
  && apt-get clean

RUN curl -sSL https://sdk.cloud.google.com | bash
ENV PATH $PATH:/root/google-cloud-sdk/bin
