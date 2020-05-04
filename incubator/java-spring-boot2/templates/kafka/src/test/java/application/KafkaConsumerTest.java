package application;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.concurrent.TimeUnit;

import org.junit.ClassRule;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.context.annotation.ComponentScan;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.test.context.EmbeddedKafka;
import org.springframework.kafka.test.rule.EmbeddedKafkaRule;
import org.springframework.test.annotation.DirtiesContext;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.context.annotation.FilterType;


@EmbeddedKafka(topics = {"orders"})
@DirtiesContext
@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
@ActiveProfiles("test")
@ComponentScan(excludeFilters = @ComponentScan.Filter(type = FilterType.ASSIGNABLE_TYPE, value = CommandLineRunner.class))
public class KafkaConsumerTest {

	private static String TOPIC_NAME = "orders";

	@Autowired
	KafkaTemplate<String, String> kafkaTemplate;

	@Autowired
	KafkaConsumer consumer;

	@ClassRule
	public static EmbeddedKafkaRule embeddedKafka = new EmbeddedKafkaRule(1, false, TOPIC_NAME);

	@Test
    public void testReceive() throws InterruptedException {
		// send the message
        kafkaTemplate.send("orders", "hello");
        consumer.getCountDownLatch().await(10000, TimeUnit.MILLISECONDS);
        // check that message was delivered
        assertThat(consumer.getCountDownLatch().getCount()).isEqualTo(0);
    }

}
