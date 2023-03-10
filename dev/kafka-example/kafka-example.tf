resource "kubernetes_manifest" "kafka_connect_build" {
  manifest = yamldecode(file("${path.module}/kafka-connect-build.yaml"))
}

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

## THSI SECTION IS KEPT TO HAVE A REFERENCE ABOUT THE .HCL SYNTAX
#resource "kubernetes_manifest" "kafka_connect_build" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaConnect"
#
#    metadata = {
#      name      = "kafka-connect"
#      namespace = "galoy-dev-kafka"
#
#      annotations = {
#        "strimzi.io/use-connector-resources" = "true"
#      }
#    }
#    spec = {
#      version          = "3.3.2"
#      replicas         = 1
#      bootstrapServers = "kafka-kafka-bootstrap:9093"
#      tls = {
#        trustedCertificates = [
#          {
#            "secretName"  = "kafka-cluster-ca-cert"
#            "certificate" = "ca.crt"
#          }
#        ]
#      }
#      config = {
#        "group.id"                          = "connect-cluster"
#        "offset.storage.topic"              = "connect-cluster-offsets"
#        "config.storage.topic"              = "connect-cluster-configs"
#        "status.storage.topic"              = "connect-cluster-status"
#        "config.storage.replication.factor" = -1
#        "offset.storage.replication.factor" = -1
#        "status.storage.replication.factor" = -1
#        build = {
#          output = {
#            "type"  = "docker"
#            "image" = "ttl.sh/strimzi-connect-example-3.4.0:24h"
#          }
#          plugins = [
#            {
#              "name" = "kafka-connect-file"
#              "artifacts" = [
#                {
#                  "type"     = "maven"
#                  "group"    = "org.apache.kafka"
#                  "artifact" = "connect-file"
#                  "version"  = "3.4.0"
#                }
#              ]
#            }
#          ]
#        }
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "kafka_connect" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaConnect"
#
#    metadata = {
#      name      = "kafka-connect"
#      namespace = "galoy-dev-kafka"
#
#      annotations = {
#        "strimzi.io/use-connector-resources" = "true"
#      }
#    }
#    spec = {
#      version          = "3.3.2"
#      image    = "ttl.sh/strimzi-connect-example3-3.4.0"
#      replicas         = 1
#      bootstrapServers = "kafka-kafka-bootstrap:9093"
#      tls = {
#        trustedCertificates = [
#          {
#            "secretName"  = "kafka-cluster-ca-cert"
#            "certificate" = "ca.crt"
#          }
#        ]
#      }
#      config = {
#        "group.id"                          = "connect-cluster"
#        "offset.storage.topic"              = "connect-cluster-offsets"
#        "config.storage.topic"              = "connect-cluster-configs"
#        "status.storage.topic"              = "connect-cluster-status"
#        "config.storage.replication.factor" = -1
#        "offset.storage.replication.factor" = -1
#        "status.storage.replication.factor" = -1
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "kafka_topic" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaTopic"
#
#    metadata = {
#      name      = "my-topic"
#      namespace = "galoy-dev-kafka"
#      labels = {
#        "strimzi.io/cluster" = "kafka-connect"
#      }
#    }
#    spec = {
#      partitions = 1
#      replicas   = 1
#      config = {
#        "retention.ms"  = 604800000
#        "segment.bytes" = 1073741824
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "kafka_source_connector" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaConnector"
#
#    metadata = {
#      name      = "kafka-source-connector"
#      namespace = "galoy-dev-kafka"
#      labels = {
#        "strimzi.io/cluster" = "kafka-connect"
#      }
#    }
#    spec = {
#      class    = "org.apache.kafka.connect.file.FileStreamSourceConnector"
#      tasksMax = 2
#      autoRestart = {
#        enabled = true
#      }
#      config = {
#        file  = "/opt/kafka/LICENSE"
#        topic = "my-topic"
#      }
#    }
#  }
#}
#
#resource "kubernetes_manifest" "kafka_sink_connector" {
#  manifest = {
#    apiVersion = "kafka.strimzi.io/v1beta2"
#    kind       = "KafkaConnector"
#
#    metadata = {
#      name      = "kafka-sink-connector"
#      namespace = "galoy-dev-kafka"
#      labels = {
#        "strimzi.io/cluster" = "kafka-connect"
#      }
#    }
#    spec = {
#      class    = "org.apache.kafka.connect.file.FileStreamSinkConnector"
#      tasksMax = 2
#      autoRestart = {
#        enabled = true
#      }
#      config = {
#        file  = "/tmp/my-file"
#        topic = "my-topic"
#      }
#    }
#  }
#}
