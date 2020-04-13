# Kafka Template

The java-spring-boot2 `kafka` template provides a consistent way of developing Spring Boot applications which connect to Kafka. This template is an extension of `default` template and uses [spring-kafka](https://spring.io/projects/spring-kafka#overview) to connect to the Kafka instance running on Kubernetes managed by [Strimzi](https://strimzi.io/) Kafka operator.

The `kafka` template provides a `pom.xml` file that references the parent POM defined by the stack, dependencies that enables the Spring boot application to connect to Kafka, simple producer that publishes a message to the Kafka topic and a simple consumer that consumes the messages published on to Kafka topic by the producer. It also provides a basic liveness endpoint, and a set of unit tests that ensure enabled actuator endpoints work properly: `/actuator/health`, `/actuator/metric`, `/actuator/prometheus` and `/actuator/liveness`

## Getting Started

1. Create a new folder in your local directory and initialize it using the Appsody CLI, e.g.:

```
mkdir my-project
cd my-project
appsody init java-spring-boot2 kafka
```
This will initialize a Spring Boot 2 project using the kafka template.

2. Once your project has been initialized you can then run your application using the following command:

```
appsody run --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=${KAFKA_BOOTSTRAP_SERVERS}"
```
E.g:
```
appsody run --network kafka_default --docker-options "--env KAFKA_BOOTSTRAP_SERVERS=kafka:9092"
```
`DOCKER_NETWORK_NAME` is the name of the docker network in which the kafka container is running.

This template expects `KAFKA_BOOTSTRAP_SERVERS` environment variable to be set to addresses of the bootstrap servers of kafka.

This launches a Docker container that will run your application in the foreground, exposing it on port 8080. You should see that the producer publishes message to the kafka topic and the consumer reads it. The application will be restarted automatically when changes are detected.

3. You should be able to access the following endpoints, as they are exposed by your template application by default:

* Health endpoint: http://localhost:8080/actuator/health
* Liveness endpoint: http://localhost:8080/actuator/liveness
* Metrics endpoint: http://localhost:8080/actuator/metrics
* Prometheus endpoint: http://localhost:8080/actuator/prometheus

4. To deploy the application to Kubernetes run the following command:
```
appsody deploy
```
Make sure to add the `KAFKA_BOOTSTRAP_SERVERS` environment variable in the `app-deploy.yaml` before running the above command

```
env:
  - name: KAFKA_BOOTSTRAP_SERVERS
    value: ${KAFKA_BOOTSTRAP_SERVERS}
```

If you are trying to connect to a Kafka instance managed by Strimzi Kafka operator, the value of `KAFKA_BOOTSTRAP_SERVERS` should be a fully qualified service hostname.

E.g: my-cluster-kafka-bootstrap.strimzi.svc.cluster.local:9092

* `my-cluster` is the Kafka resource name.
* `kafka-bootstrap` is the Broker load balancer name.
* `strimzi` is the namespace in which Kafka instance is deployed.
* `9092` is the PLAINTEXT port.

5. To deploy the application that connects to kafka managed by Strimzi operator where the brokers support TLS Client authentication

Add the following properties to `application.properties`

```
spring.kafka.properties.security.protocol=ssl
spring.kafka.properties.ssl.protocol=ssl
spring.kafka.properties.ssl.truststore.location=/etc/secrets/keystores/truststore.p12
spring.kafka.properties.ssl.truststore.password=changeit
spring.kafka.properties.ssl.truststore.type=${TRUSTSTORE_PASSWORD}
spring.kafka.properties.ssl.keystore.location=/etc/secrets/keystores/keystore.p12
spring.kafka.properties.ssl.keystore.password=${KEYSTORE_PASSWORD}
spring.kafka.properties.ssl.keystore.type=PKCS12
spring.kafka.properties.ssl.key.password=${KEYSTORE_PASSWORD}
spring.kafka.properties.ssl.endpoint.identification.algorithm=
```

`TRUSTSTORE_PASSWORD` is the password that you have used when creating the truststore.

`KEYSTORE_PASSWORD` is the password that you have used when creating the keystore.

Next, add the following in the `app-deploy.yaml` under `spec` section

* Add the following volumes

```
volumes:
# emptyDir volume to store the keystore and truststore files so that the application container can eventually read them.
- emtpyDir: {}
  name: keystore-volume
# this is the secret that is created when the kafka user is created  
- name: my-user-credentials
  secret:
    secretName: my-user
# secret that holds CA certificate created by the operator for the brokers
- name: my-cluster-cluster-ca-cert
  secret:
    secretName: my-cluster-cluster-ca-cert
```
* Volume mount the `keystore-volume`

```
volumeMounts:
- mountPath: /etc/secrets/keystores
  name: keystore-volume
```
* Add `KAFKA_BOOTSTRAP_SERVERS` environment variable. E.g.:

```
env:
- name: KAFKA_BOOTSTRAP_SERVERS
  value: my-cluster-kafka-bootstrap.kafka.svc.cluster.local:9093
```
`9093` is the TLS port.

* Add `initContainers` that generate the keystore and truststore which will eventually be used by the application container.

```
initContainers:
- args:
  - -c
  - echo $ca_bundle && csplit -z -f crt- $ca_bundle '/-----BEGIN CERTIFICATE-----/'
    '{*}' && for file in crt-*; do keytool -import -noprompt -keystore $truststore_jks
    -file $file -storepass $password -storetype PKCS12 -alias service-$file; done
  command:
  - /bin/bash
  env:
  - name: ca_bundle
    value: /etc/secrets/my-cluster-cluster-ca-cert/ca.crt
  - name: truststore_jks
    value: /etc/secrets/keystores/truststore.p12
  - name: password
    value: ${TRUSTSTORE_PASSWORD}
  image: registry.access.redhat.com/redhat-sso-7/sso71-openshift:1.1-16
  name: pem-to-truststore
  volumeMounts:
  - mountPath: /etc/secrets/keystores
    name: keystore-volume
  - mountPath: /etc/secrets/my-user
    name: my-user-credentials
    readOnly: true
  - mountPath: /etc/secrets/my-cluster-cluster-ca-cert
    name: my-cluster-cluster-ca-cert
    readOnly: true
- args:
  - -c
  - openssl pkcs12 -export -inkey $keyfile -in $crtfile -out $keystore_pkcs12 -password
    pass:$password -name "name"
  command:
  - /bin/bash
  env:
  - name: keyfile
    value: /etc/secrets/my-user/user.key
  - name: crtfile
    value: /etc/secrets/my-user/user.crt
  - name: keystore_pkcs12
    value: /etc/secrets/keystores/keystore.p12
  - name: password
    value: ${KEYSTORE_PASSWORD}
  image: registry.access.redhat.com/redhat-sso-7/sso71-openshift:1.1-16
  name: pem-to-keystore
  volumeMounts:
  - mountPath: /etc/secrets/keystores
    name: keystore-volume
  - mountPath: /etc/secrets/my-user
    name: my-user-credentials
    readOnly: true
```
** Here `my-user` is the kafka user and `my-cluster` is the kafka cluster name.
