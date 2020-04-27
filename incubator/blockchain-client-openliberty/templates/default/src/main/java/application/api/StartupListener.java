package application.api;

import java.util.logging.Logger;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.GatewayException;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;

import application.cm.ConnectionConfiguration;
import application.cm.ConnectionManager;

@WebListener
public class StartupListener implements ServletContextListener {

    private static final Logger LOGGER = Logger.getLogger(StartupListener.class.getName());

    public void contextInitialized(ServletContextEvent sce) {
        LOGGER.info("Application being initialized.");
        String defaultIdentity = ConnectionConfiguration.getFabricDefaultIdentity();
        LOGGER.info("Identity: " + defaultIdentity);
        try {
            Contract c = ConnectionManager.getContract(defaultIdentity);
            LOGGER.info("Contract : " +  c.toString());
        } catch (IdentityException e) {
            LOGGER.severe(e.toString());
        } catch (GatewayException e) {
            LOGGER.severe(e.toString());
        }
    }
}