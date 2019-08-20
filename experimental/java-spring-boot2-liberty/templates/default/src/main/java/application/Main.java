package application;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.actuate.endpoint.annotation.Endpoint;
import org.springframework.boot.actuate.endpoint.annotation.ReadOperation;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.stereotype.Component;

@SpringBootApplication
public class Main {

	public static void main(String[] args) {
		SpringApplication.run(Main.class, args);
	}

	// Simple custom liveness check
	@Endpoint(id = "liveness")
	@Component
	public class Liveness {
		@ReadOperation
		public String testLiveness() {
			return "{\"status\":\"UP\"}";
		}
	}
}
