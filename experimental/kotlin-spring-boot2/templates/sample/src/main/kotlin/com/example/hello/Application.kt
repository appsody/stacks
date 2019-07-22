package com.example.hello

import org.springframework.boot.autoconfigure.SpringBootApplication
import org.springframework.boot.runApplication
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.stereotype.Component;

@SpringBootApplication
class HelloWorldApp {

    @Endpoint(id = "liveness")
    @Component
    class Liveness {
        @ReadOperation
	public fun testLiveness(): String {
            return "{\"status\":\"UP\"}";
	}
    }
}

fun main(args: Array<String>) {
    runApplication<HelloWorldApp>(*args)
}
