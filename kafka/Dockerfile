FROM openjdk:8u292-slim-buster

WORKDIR /opt

ARG kafkaversion=3.3.1
ARG scalaversion=2.13

ARG KRAFT_BPORT
ARG KRAFT_CPORT

ENV KRAFT_CONTAINER_HOST_NAME=
ENV KRAFT_CREATE_TOPICS=
ENV KRAFT_PARTITIONS_PER_TOPIC=

RUN apt update \
    && apt install -y --no-install-recommends wget

RUN wget https://downloads.apache.org/kafka/${kafkaversion}/kafka_${scalaversion}-${kafkaversion}.tgz -O kafka.tgz \
    && tar xvzf kafka.tgz \
    && mv kafka_${scalaversion}-${kafkaversion} kafka

WORKDIR /opt/kafka

COPY ./conf/server.properties ./config/kraft
COPY ./*.sh .

EXPOSE $KRAFT_BPORT $KRAFT_CPORT

ENTRYPOINT [ "./docker-entrypoint.sh" ]