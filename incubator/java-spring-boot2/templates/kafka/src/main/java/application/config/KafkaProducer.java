package application.config;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.core.KafkaTemplate;

import application.KafkaConsumer;

import java.util.UUID;

@Configuration
public class KafkaProducer {

    @Autowired
    KafkaTemplate<String, String> kafkaTemplate;
    
	private static String TOPIC_NAME = "orders";

    // a simple kafka producer that publishes a message to the "orders" topic after the application is initialized 
    @Bean
    public CommandLineRunner kafkaCommandLineRunner(KafkaConsumer kafkaConsumer) {
        return args -> {
            String data = "testData:" + UUID.randomUUID();
            System.out.println("Sending message to kafka = " + data);
            kafkaTemplate.send(TOPIC_NAME, data);
            kafkaConsumer.getCountDownLatch().await();
        };
    }
}
