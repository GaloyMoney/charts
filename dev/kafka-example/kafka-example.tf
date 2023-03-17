#resource "kubernetes_manifest" "kafka_user" {
#  manifest = yamldecode(file("${path.module}/kafka-user.yaml"))
#}

#resource "kubernetes_manifest" "kafka_connect_build" {
#  manifest = yamldecode(file("${path.module}/kafka-connect-build.yaml"))
#}

resource "kubernetes_manifest" "kafka_connect" {
  manifest = yamldecode(file("${path.module}/kafka-connect.yaml"))
}

#resource "kubernetes_manifest" "kafka_topic" {
#  manifest = yamldecode(file("${path.module}/kafka-topic.yaml"))
#}

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