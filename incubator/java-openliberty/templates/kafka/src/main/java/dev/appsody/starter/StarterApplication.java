package dev.appsody.starter;


import org.eclipse.microprofile.reactive.messaging.Incoming;
import org.eclipse.microprofile.reactive.messaging.Outgoing;
import javax.enterprise.context.ApplicationScoped;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@ApplicationScoped
public class StarterApplication {
    private static Logger logger = LoggerFactory.getLogger(StarterApplication.class);
    private String receivedMessage;

    /**
     * Process an event from one topic and emit a result to another.
     * @param message
     * @return
     */
    @Incoming("incomingTopic1")
    @Outgoing("outgoingTopic1")
    public String processMessage(String message) {
        String completeMessage = "Hello " + message;
        logger.info("Message " + completeMessage);
        return completeMessage;
    }

    /**
     * Receive an event. This could be used to do something else with the data
     * such as writing it to a database.
     * @param message
     */
    @Incoming("incomingTopic2")
    public void receiveMessage(String message) {
        receivedMessage = message;
        logger.info("Message " + message);
    }

	public String getReceivedMessage() {
		return receivedMessage;
	}
}
