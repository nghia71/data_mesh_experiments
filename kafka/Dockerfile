FROM openjdk:8u292-slim-buster

WORKDIR /opt

ARG kafkaversion=3.3.1
ARG scalaversion=2.13

RUN apt update \
    && apt install -y --no-install-recommends wget

RUN wget https://downloads.apache.org/kafka/${kafkaversion}/kafka_${scalaversion}-${kafkaversion}.tgz -O kafka.tgz \
    && tar xvzf kafka.tgz \
    && mv kafka_${scalaversion}-${kafkaversion} kafka

WORKDIR /opt/kafka

COPY ./conf/server.properties ./config/kraft/.
COPY ./*.sh .

RUN echo "Setting up Kafka storage ...";
RUN ./bin/kafka-storage.sh format -t $KAFKA_STORAGE_UUID -c ./config/kraft/server.properties;
RUN echo "Kafka storage ${KAFKA_STORAGE_UUID} setup ✅";

RUN echo "Setting up Kafka storage ...";
RUN ./bin/kafka-storage.sh format -t $KAFKA_STORAGE_UUID -c ./config/kraft/server.properties;
RUN echo "Kafka storage ${KAFKA_STORAGE_UUID} setup ✅";

RUN echo "Exposing ports ${KRAFT_BROKER_PORT} ${KRAFT_CONTROLLER_PORT} ✅";
EXPOSE $KRAFT_BROKER_PORT $KRAFT_CONTROLLER_PORT

RUN echo "Starting Kafka server...";
CMD ["./bin/kafka-server-start.sh", "./config/kraft/server.properties"]

# ENTRYPOINT [ "./docker-entrypoint.sh" ]