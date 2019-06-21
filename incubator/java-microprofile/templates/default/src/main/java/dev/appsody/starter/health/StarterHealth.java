package dev.appsody.starter.health;

import javax.enterprise.context.ApplicationScoped;


import org.eclipse.microprofile.health.Health;
import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;

@Health
@ApplicationScoped
public class StarterHealth implements HealthCheck {

    private boolean isHealthy() {
        // perform health checks here

        return true;
    }
	
    @Override
    public HealthCheckResponse call() {
        boolean up = isHealthy();
        return HealthCheckResponse.named("StarterService").state(up).build();
    }
    
}
