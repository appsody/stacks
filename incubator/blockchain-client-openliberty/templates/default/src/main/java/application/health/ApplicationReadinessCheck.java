package application.health;

import javax.enterprise.context.ApplicationScoped;
import java.util.logging.Logger;

import org.eclipse.microprofile.health.HealthCheck;
import org.eclipse.microprofile.health.HealthCheckResponse;
import org.eclipse.microprofile.health.Readiness;
import application.utils.ConnectionConfiguration;

@Readiness
@ApplicationScoped
public class ApplicationReadinessCheck implements HealthCheck {
    public static final Logger LOGGER = Logger.getLogger(ApplicationReadinessCheck.class.getName());

    private boolean isReady() {
        // perform readiness checks, e.g. database connection, etc.
        if (ConnectionConfiguration.getChannel() == null || ConnectionConfiguration.getChannel().isEmpty()) {
            LOGGER.severe("Channel environment variable not provided... app not ready.");
            return false;
        }
        if (ConnectionConfiguration.getConnectionProfile() == null || ConnectionConfiguration.getConnectionProfile().isEmpty()) {
            LOGGER.severe("Connection profile environment variable not provided... app not ready.");
            return false;
        }
        if (ConnectionConfiguration.getContractId() == null || ConnectionConfiguration.getContractId().isEmpty()) {
            LOGGER.severe("Contract id environment variable not provided... app not ready.");
            return false;
        }            
        return true;
    }
	
    @Override
    public HealthCheckResponse call() {
        boolean up = isReady();
        return HealthCheckResponse.named(this.getClass().getSimpleName()).state(up).build();
    }
    
}
