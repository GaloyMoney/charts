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

resource "kubernetes_manifest" "kafka_source_connector" {
  manifest = yamldecode(file("${path.module}/kafka-source-connector.yaml"))
}

resource "kubernetes_manifest" "kafka_sink_connector" {
  manifest = yamldecode(file("${path.module}/kafka-sink-connector.yaml"))
}
