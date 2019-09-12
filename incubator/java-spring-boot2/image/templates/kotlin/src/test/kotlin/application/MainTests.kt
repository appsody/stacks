package application

import kotlin.collections.List
import kotlin.collections.Map

import org.junit.Assert.assertEquals
import org.junit.Assert.assertNotNull
import org.junit.Assert.assertTrue
import org.junit.Test
import org.junit.runner.RunWith
import org.springframework.beans.factory.annotation.Autowired
import org.springframework.boot.test.context.SpringBootTest
import org.springframework.boot.test.web.client.TestRestTemplate
import org.springframework.http.HttpStatus
import org.springframework.http.ResponseEntity
import org.springframework.test.context.junit4.SpringRunner

@RunWith(SpringRunner::class)
@SpringBootTest(
    classes = arrayOf(Main::class),
    webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
class MainTests {
    var result = """{"status":"UP"}"""

    @Autowired
    lateinit var restTemplate: TestRestTemplate

    @Test
    fun healthCheck_shouldReturnUP() {
        val entity = restTemplate.getForEntity("/actuator/health", String::class.java)

        assertNotNull(entity)
        assertEquals(HttpStatus.OK, entity.statusCode)

        assertNotNull(entity.body)
        assertEquals(result, entity.body)
    }

    @Test
    fun liveness_shouldReturnUP() {
        val entity = restTemplate.getForEntity("/actuator/liveness", String::class.java)

        assertNotNull(entity)
        assertEquals(HttpStatus.OK, entity.statusCode)

        assertNotNull(entity.body)
        assertEquals(result, entity.body)
    }

}
