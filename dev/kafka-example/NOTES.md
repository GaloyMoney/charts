# deploying the kafka-example components

## Connect docs
https://kafka.apache.org/documentation/#connect
## Build docs
https://strimzi.io/blog/2021/03/29/connector-build/
https://github.com/strimzi/strimzi-kafka-operator/blob/main/documentation/api/io.strimzi.api.kafka.model.connect.build.Build.adoc
## Create Docker credentials:
https://kubernetes.io/docs/tasks/configure-pod-container/pull-image-private-registry/
```
 docker login
 cat ~/.docker/config.json
 kubectl -n galoy-dev-kafka create secret generic regcred \
    --from-file=.dockerconfigjson=$HOME/.docker/config.json \
    --type=kubernetes.io/dockerconfigjson
 kubectl -n galoy-dev-kafka get secret regcred --output=yaml
```
## manifests
```
# use this to build a new image - it builds and runs the kafka-conncet pod afterwards
tf apply -target kubernetes_manifest.kafka_connect_build --auto-approve

  k describe KafkaConnect -A
  k -n galoy-dev-kafka   logs     kafka-connect-connect-build
  tf destroy -target kubernetes_manifest.kafka_connect_build --auto-approve
  k -n galoy-dev-kafka  delete pod      kafka-connect-connect-build --force

# use this when there is an image available already
tf apply -target kubernetes_manifest.kafka_connect --auto-approve

tf apply -target kubernetes_manifest.kafka_topic --auto-approve
k describe KafkaTopic -A

tf apply -target kubernetes_manifest.kafka_source_mongo --auto-approve

tf apply -target kubernetes_manifest.kafka_sink_connector --auto-approve

# list the KafkaConnector kinds (source and sink)
kubectl get KafkaConnector --selector strimzi.io/cluster=kafka-connect -o name

# logs
k -n galoy-dev-kafka logs -f $(kubectl -n galoy-dev-kafka get pods | grep connect | awk '{print $1}')

```


## Test
https://strimzi.io/quickstarts/

* add messages
```
kubectl -n galoy-dev-kafka exec -it kafka-kafka-0 -- \
bin/kafka-console-producer.sh --bootstrap-server kafka-kafka-bootstrap:9092 \
--topic my-topic
```
* read messages
```
kubectl -n galoy-dev-kafka exec -it kafka-kafka-0 -- \
bin/kafka-console-consumer.sh --bootstrap-server kafka-kafka-bootstrap:9092 \
--topic my-topic --from-beginning
```
## plugins
* pkg:maven/org.apache.kafka/connect-file@3.4.0
* pkg:maven/org.mongodb.kafka/mongo-kafka-connect@1.9.1

## Mongo source:
* https://github.com/mongodb/mongo-kafka/blob/master/README.md
* https://docs.mongodb.com/kafka-connector/current/
* https://central.sonatype.com/artifact/org.mongodb.kafka/mongo-kafka-connect/1.9.1
* https://www.mongodb.com/docs/kafka-connector/current/introduction/converters/
* https://www.mongodb.com/docs/kafka-connector/current/tutorials/source-connector/#std-label-kafka-tutorial-source-connector
```
# mongosh
k -n galoy-dev-galoy exec -it galoy-mongodb-0 -- mongosh
use galoy
db.auth('testGaloy','password')
use admin
db.auth('root','password')
rs.status()

# add values to mongodb
db.changelog.insertOne({
  field1: "value1",
  field2: "value2",
  field3: "value3"
});

# for Mongo Compass
ssh k3d@dev_server_IP -L 27018:127.0.0.1:27017
k -n galoy-dev-galoy port-forward svc/galoy-mongodb 27017:27017

# helpers
k -n galoy-dev-kafka get kt
k -n galoy-dev-kafka describe KafkaConnector kafka-source-mongo
kubectl -n galoy-dev-kafka logs -f deployment/kafka-connect 
kubectl -n galoy-dev-kafka get KafkaConnector
```
```
# create topics
bash ./../bin/create-topic-manifests.sh
```
Bigquery sink
https://www.confluent.io/hub/wepay/kafka-connect-bigquery
https://docs.confluent.io/kafka-connectors/bigquery/current/overview.html#dead-letter-queue
https://github.com/confluentinc/kafka-connect-bigquery
https://cloud.google.com/dataflow/docs/kafka-dataflow
https://docs.aiven.io/docs/products/kafka/kafka-connect/howto/gcp-bigquery-sink
https://infinitelambda.com/postgresql-bigquery-sync-pipeline-debezium-kafka/

# TODO
- [x] create a permanent docker image store - can be personal docker hub for testing
- [x] find a reliable way to test the data flow
- [x] set up the mongodb source connector
- [ ] set up the bigquery sink connector
- [ ] set up the strimzi grafana dashboard

