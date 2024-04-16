FROM python:3.8-buster

RUN apt-get update \
  && apt-get install -y bash curl wget tar git gettext jq perl \
  && apt-get clean

ARG OK
ENV OK ${OK}

ARG TEST
ENV TEST ${TEST}
