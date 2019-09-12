package application

import org.springframework.web.bind.annotation.RestController
import org.springframework.web.bind.annotation.GetMapping

@RestController
class Hello {

    @GetMapping("/hello")
    fun hello(): String {
        return "Hello, Appsody!"
    }
}
