package com.example.hello.tests

import org.assertj.core.api.Assertions.*

import org.junit.Test
import org.junit.runner.RunWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.context.SpringBootTest.WebEnvironment
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.test.context.junit4.SpringRunner

@RunWith(SpringRunner::class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
public class MainTests {

    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Test
    fun testHealthEndpoint() {
        val result = restTemplate.getForEntity("/actuator/health", String::class.java)
        assertThat(result.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(result.body).contains("\"status\":\"UP\"")
    }

    @Test
    fun testLivenessEndpoint() {
        val result = restTemplate.getForEntity("/actuator/health", String::class.java)
        assertThat(result.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(result.body).contains("\"status\":\"UP\"")    
    }

    @Test
    fun testPrometheusEndpoint() {
        val result = restTemplate.getForEntity("/actuator/prometheus", String::class.java)
        assertThat(result.statusCode).isEqualTo(HttpStatus.OK)
        assertThat(result.body).contains("# TYPE jvm_buffer_count_buffers gauge")
    }

    @Test
    fun testMetricsEndpoint() {
        testLivenessEndpoint()

        @SuppressWarnings("rawtypes")
        val entity = restTemplate.getForEntity("/actuator/metrics", Map::class.java)
        assertThat(entity.statusCode).isEqualTo(HttpStatus.OK)

        @Suppress("UNCHECKED_CAST")
        val values: ArrayList<*> = (entity.body?.get("names") as? ArrayList<String>) ?: ArrayList<String>()
        assertThat(values).contains("jvm.buffer.count")
    }
}
