# deploying the kafka-example components

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

tf apply -target kubernetes_manifest.kafka_source_connector --auto-approve

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

# TODO
- [x] create a permanent docker image store - can be personal docker hub for testing
- [x] find a reliable way to test the data flow
- [ ] introduce the mongodb source connector
- [ ] introduce the bigquery sink connector