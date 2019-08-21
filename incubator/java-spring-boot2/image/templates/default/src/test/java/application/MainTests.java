package application;

import static org.assertj.core.api.Assertions.assertThat;

import java.util.List;
import java.util.Map;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment;
import org.springframework.boot.test.web.client.TestRestTemplate;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.junit4.SpringRunner;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = WebEnvironment.RANDOM_PORT)
public class MainTests {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    public void testHealthEndpoint() {
        ResponseEntity<String> entity = this.restTemplate.getForEntity("/actuator/health", String.class);
        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(entity.getBody()).contains("\"status\":\"UP\"");
    }

    @Test
    public void testLivenessEndpoint() {
        ResponseEntity<String> entity = this.restTemplate.getForEntity("/actuator/liveness", String.class);
        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(entity.getBody()).contains("\"status\":\"UP\"");
    }

    @Test
    @SuppressWarnings("unchecked")
    public void testMetricsEndpoint() {
        testLivenessEndpoint(); // access a page

        @SuppressWarnings("rawtypes")
        ResponseEntity<Map> entity = this.restTemplate.getForEntity("/actuator/metrics", Map.class);
        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.OK);

        Map<String, Object> body = entity.getBody();
        assertThat(body).containsKey("names");
        assertThat((List<String>) body.get("names")).contains("jvm.buffer.count");
    }

    @Test
    public void testPrometheusEndpoint() {
        testLivenessEndpoint(); // access a page

        ResponseEntity<String> entity = this.restTemplate.getForEntity("/actuator/prometheus", String.class);
        assertThat(entity.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(entity.getBody()).contains("# TYPE jvm_buffer_count_buffers gauge");
    }
}
