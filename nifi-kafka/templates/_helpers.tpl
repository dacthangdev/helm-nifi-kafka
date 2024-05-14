{{/*
Expand the name of the chart.
*/}}
{{- define "Nifi_Kafka.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "Nifi_Kafka.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "Nifi_Kafka.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "Nifi_Kafka.labels" -}}
helm.sh/chart: {{ include "Nifi_Kafka.chart" . }}
{{ include "Nifi_Kafka.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "Nifi_Kafka.selectorLabels" -}}
app.kubernetes.io/name: {{ include "Nifi_Kafka.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "Nifi_Kafka.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "Nifi_Kafka.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}


{{/*
Create containers Kafka
*/}}

{{- define "Kafka.container" -}}
- env:
    - name: KAFKA_BROKER_ID
      value: "8"
    - name: KAFKA_CFG_ZOOKEEPER_CONNECT
      value: "{{ .Values.service.name.zookeeper }}"
    - name: KAFKA_ADVERTISED_PORT
      value: "{{ .Values.service.ports.kafka.portBroker }}"
    - name: KAFKA_ADVERTISED_HOST_NAME
      value: "{{ .Values.service.name.kafka }}"
    - name: ALLOW_PLAINTEXT_LISTENER
      value: "yes"
    - name: KAFKA_JMX_PORT
      value: "5555"
    - name: KAFKA_CLEANUP_POLICY
      value: "compact"
  image: harbor.sharing.ncc.local/ncfc/kafka:latest
  name: kafka-broker
  ports:
    - containerPort: 9092
{{- end -}}


{{/*
Create containers Zookeeper
*/}}

{{- define "Zookeeper.container" -}}
- image: harbor.sharing.ncc.local/ncfc/zookeeper:latest
  name: zookeeper
  env:
    - name: ALLOW_ANONYMOUS_LOGIN
      value: "yes"
    - name: ZOO_SERVER_ID
      value: "1"
    - name: ZOOKEEPER_SERVER_1
      value: "zookeeper1"
  ports:
    - containerPort: 2121
{{- end -}}

{{/*
Create containers Nifi
*/}}

{{- define "Nifi.container" -}}
- env:
    - name: NIFI_WEB_HTTP_PORT
      value: "8080"
  image: harbor.sharing.ncc.local/ncfc/nifi:latest
  name: nifi
  ports:
    - containerPort: 8080
{{- end -}}



