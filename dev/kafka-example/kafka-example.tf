#resource "kubernetes_manifest" "kafka_user" {
#  manifest = yamldecode(file("${path.module}/kafka-user.yaml"))
#}

#resource "kubernetes_manifest" "kafka_connect_build" {
#  manifest = yamldecode(file("${path.module}/kafka-connect-build.yaml"))
#}

resource "kubernetes_manifest" "kafka_connect" {
  manifest = yamldecode(file("${path.module}/kafka-connect.yaml"))
}

resource "kubernetes_manifest" "kafka_topic" {
  manifest = yamldecode(file("${path.module}/kafka-topic.yaml"))
}

locals {
  kafka_topics_files = [
    "kafka-topic-mongodb-accounts.yaml",
    "kafka-topic-mongodb-changelog.yaml",
    "kafka-topic-mongodb-dbmetadatas.yaml",
    "kafka-topic-mongodb-invoiceusers.yaml",
    "kafka-topic-mongodb-lnpayments.yaml",
    "kafka-topic-mongodb-medici-balances.yaml",
    "kafka-topic-mongodb-medici-journals.yaml",
    "kafka-topic-mongodb-medici-locks.yaml",
    "kafka-topic-mongodb-medici-transaction-metadatas.yaml",
    "kafka-topic-mongodb-medici-transactions.yaml",
    "kafka-topic-mongodb-payment-flow-states.yaml"
  ]
  kafka_topics_content = flatten([
    for file in local.kafka_topics_files : [
      yamldecode(file("${path.module}/topics/${file}"))
    ]
  ])
}

resource "kubernetes_manifest" "kafka_topics_mongodb" {
  for_each = { for obj in local.kafka_topics_content : "${obj.metadata.name}" => obj }
  manifest = each.value
}

resource "kubernetes_manifest" "kafka_source_file" {
  manifest = yamldecode(file("${path.module}/kafka-source-file.yaml"))
}

resource "kubernetes_manifest" "kafka_source_mongo" {
  manifest = yamldecode(file("${path.module}/kafka-source-mongo.yaml"))
}

resource "kubernetes_manifest" "kafka_sink_file" {
  manifest = yamldecode(file("${path.module}/kafka-sink-file.yaml"))
}

resource "kubernetes_manifest" "kafka_sink_bigquery" {
  manifest = yamldecode(file("${path.module}/kafka-sink-bigquery.yaml"))
}
