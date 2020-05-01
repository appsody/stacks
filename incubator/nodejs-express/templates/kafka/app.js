const express = require('express');

module.exports = (options) => {
  // Kafka is a required node-rdkafka:
  // - api docs: https://blizzard.github.io/node-rdkafka/current/
  // - quick start: https://github.com/Blizzard/node-rdkafka#usage
  const Kafka = require('node-rdkafka');

  // options.log is a pino logger:
  // - https://github.com/pinojs/pino/blob/master/docs/api.md#logger
  const log = options.log;

  const app = express();

  app.get('/', (req, res) => {
    res.send('Hello from Appsody!');
  });

  // KAFKA_BOOTSTRAP_SERVERS can be injected by the Service Binding Operator
  // - https://github.com/redhat-developer/service-binding-operator
  const brokers = process.env.KAFKA_BOOTSTRAP_SERVERS || 'localhost:9092'

  log.info('Kafka features: %s', Kafka.features);
  log.info('Kafka brokers: %s', brokers);

  // Based on:
  // - https://github.com/ibm-messaging/event-streams-samples/blob/master/kafka-nodejs-console-sample/app.js#L145
  const config = {
    // debug: 'all',  // Setting will cause 'event.log' events.
    'metadata.broker.list': brokers,
    // 'log.connection.close' : false,
  }

  Produce(Kafka, config, log, app);
  Consume(Kafka, brokers, log);

  return app;
};

// Based on:
// - https://github.com/Blizzard/node-rdkafka/blob/master/examples/producer.md
// - https://github.com/ibm-messaging/event-streams-samples/blob/master/kafka-nodejs-console-sample/producerLoop.js
function Produce(Kafka, config, log, app) {
  config.dr_msg_cb = true;  // Enable delivery reports with message payload
  var producer = new Kafka.Producer(config);
  var topicName = 'my-topic';

  producer.setPollInterval(100);

  // only if debug option set in config
  producer.on('event.log', function(msg) {
    log.debug('debug from producer:', msg);
  });

  // logging all errors
  producer.on('event.error', function(err) {
    log.error('error from producer: %s', err);
  });

  // wait for the ready event before producing
  producer.on('ready', function(arg) {
    log.info(arg, 'producer ready');
  });

  // log delivery reports
  producer.on('delivery-report', function(err, dr) {
    if (err) {
      log.error('Delivery failed: %j', err);
      // consider retrying
    } else {
      log.info('Delivery success: %j', dr);
    }
  });

  app.use(express.json());
  app.post("/produce", function(req, res) {
    log.info({value: req.body}, "produce from POST");

    // if partition is set to -1, librdkafka will use the default partitioner
    const partition = -1;
    const value = Buffer.from(JSON.stringify(req.body));
    try {
      producer.produce(topicName, partition, value);
      res.send("ok");
    } catch(err) {
      log.error('Production failed: %j', err);
    }
  });

  // starting the producer
  producer.connect();
}

// Based on:
// - https://github.com/Blizzard/node-rdkafka/blob/master/examples/consumer-flow.md
// - https://github.com/ibm-messaging/event-streams-samples/blob/master/kafka-nodejs-console-sample/consumerLoop.js
function Consume(Kafka, brokers, log) {
  var consumer = new Kafka.KafkaConsumer({
    'metadata.broker.list': brokers,
    'group.id': 'my-group-id',
    'enable.auto.commit': false
  });

  var topicName = 'my-topic';

  // logging all errors
  consumer.on('event.error', function(err) {
    log.error('error from consumer: %s', err);
  });

  // counter to commit offsets every numMessages are received
  var counter = 0;
  var numMessages = 5;

  consumer.on('ready', function(arg) {
    log.info(arg, 'consumer ready');

    consumer.subscribe([topicName]);
    // start consuming messages
    consumer.consume();
  });

  consumer.on('data', function(m) {
    counter++;

    // committing offsets every numMessages
    if (counter % numMessages === 0) {
      log.info('calling commit');
      consumer.commit(m);
    }

    // convert value to JSON (if it is) before logging
    try {
      m.value = JSON.parse(m.value.toString());
    } catch {
    }

    // convert key to string before logging
    if (m.key)
      m.key = m.key.toString() ;

    // Output the actual message contents
    log.info(m, 'data received');
  });

  // starting the consumer
  consumer.connect();
}
