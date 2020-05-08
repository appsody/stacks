package application.health;

import javax.enterprise.context.ApplicationScoped;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Liveness;

@Liveness
@ApplicationScoped
public class ApplicationLivenessCheck implements HealthCheck {

    private boolean isAlive() {
        // perform health checks here

        return true; 
    }
	
    @Override
    public HealthCheckResponse call() {
        boolean up = isAlive();
        return HealthCheckResponse.named(this.getClass().getSimpleName()).state(up).build();
    }
    
}
