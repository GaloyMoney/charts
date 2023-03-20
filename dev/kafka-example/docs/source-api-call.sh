kubectl port-forward -n galoy-dev-kafka svc/kafka-connect-api 8083

curl -X POST \
     -H "Content-Type: application/json" \
     --data '
     {
         "apiVersion": "kafka.strimzi.io/v1beta2",
         "kind": "KafkaConnector",
         "metadata": {
             "name": "kafka-source-mongo",
             "namespace": "galoy-dev-kafka",
             "labels": {
                 "strimzi.io/cluster": "kafka"
             }
         },
         "spec": {
             "class": "com.mongodb.kafka.connect.MongoSourceConnector",
             "tasksMax": 1,
             "config": {
                 "connection.uri": "mongodb://testGaloy:password@galoy-mongodb.galoy-dev-galoy.svc.cluster.local:27017/?authSource=galoy$rreplicaSet=rs0"
                 database": "galoy, test",
                 "collection": "accounts,changelog,dbmetadatas,invoiceusers,lnpayments,medici_balances,medici_journals,medici_locks,medici_transaction_metadatas,medici_transactions,payment_flow_states,test",
                 "pipeline": "[{\"$match\": {\"operationType\": \"insert\"}}, {\"$addFields\" : {\"fullDocument.travel\":\"MongoDB Kafka Connector\"}}]",
                 "topic.prefix": "mongodb-",
                 "auto.create": true
             }
         }
     }
     ' \
     http://127.0.0.1:8083/apis/kafka.strimzi.io/v1beta2/namespaces/galoy-dev-kafka/kafkaconnectors -w "\n"



curl http://127.0.0.1:8083/connectors -w "\n"