package dev.appsody.starter;

import static org.junit.jupiter.api.Assertions.assertEquals;

import org.junit.jupiter.api.Test;

public class StarterApplicationTest {


    @Test
    public void testProcessMessage() {
        StarterApplication app = new StarterApplication();

        String result = app.processMessage("World");

        assertEquals("Hello World", result);
    }

    @Test
    public void testReceiveMessage() {
        StarterApplication app = new StarterApplication();

        app.receiveMessage("Banana");

        assertEquals("Banana", app.getReceivedMessage());
        
    }

}