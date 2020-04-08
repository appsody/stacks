package application;

import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.stereotype.Service;

import java.util.concurrent.CountDownLatch;

// a simple kafka consumer
@Service
public class KafkaConsumer {
    private final CountDownLatch countDownLatch = new CountDownLatch(1);

    @KafkaListener(topics = "orders", groupId = "orders-service")
    public void receiveString(String message) {
        System.out.println("Receiving message = " + message);
        countDownLatch.countDown();
    }

    public CountDownLatch getCountDownLatch() {
        return countDownLatch;
    }
}
