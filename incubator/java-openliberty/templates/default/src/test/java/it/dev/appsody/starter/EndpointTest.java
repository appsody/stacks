package it.dev.appsody.starter;

import static org.junit.jupiter.api.Assertions.assertEquals;

import javax.json.JsonObject;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.Response;

import org.apache.cxf.jaxrs.provider.jsrjsonp.JsrJsonpProvider;
import org.junit.jupiter.api.AfterEach;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class EndpointTest {
    
    private static String baseUrl;
    private static final String RESOURCE_ENDPOINT = "/starter/resource";
    private Client client;
    private Response response;
    
    @BeforeAll
    public static void oneTimeSetup() {
        String port = System.getProperty("liberty.test.port");
        baseUrl = "http://localhost:" + port;
    }
    
    @BeforeEach
    public void setup() {
        response = null;
        client = ClientBuilder.newClient();
        client.register(JsrJsonpProvider.class);
    }
    
    @AfterEach
    public void teardown() {
        response.close();
        client.close();
    }

    @Test
    public void testResourceEndpoint() {
        checkEndpoint(RESOURCE_ENDPOINT, "StarterResource response");

    }

    private void checkEndpoint(String endpoint, String expectedResponseText) {
        String resourceUrl = baseUrl + endpoint;
        response = this.getResponse(resourceUrl);
        this.assertResponse(resourceUrl, response);
        
        String responseText = response.readEntity(String.class);
        assertEquals(expectedResponseText, responseText, "Endpoint response text is not correct");
    }
    
    /**
     * <p>
     * Returns response information from the specified URL.
     * </p>
     *
     * @param url
     *          - target URL.
     * @return Response object with the response from the specified URL.
     */
    private Response getResponse(String url) {
        return client.target(url).request().get();
    }

    /**
     * <p>
     * Asserts that the given URL has the correct response code of 200.
     * </p>
     *
     * @param url
     *          - target URL.
     * @param response
     *          - response received from the target URL.
     */
    private void assertResponse(String url, Response response) {
        assertEquals(200, response.getStatus(), "Incorrect response code from " + url);
    }

}
