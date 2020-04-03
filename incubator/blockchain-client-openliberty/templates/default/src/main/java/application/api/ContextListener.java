package application.api;
// Awaits for a GatewayFactory to be up

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

//TODO: initialize identity service

@WebListener
public class ContextListener implements ServletContextListener {
    public void contextInitialized(ServletContextEvent sce){
        // System.out.println("init succeeded");
        // BlockchainClient.getInstance();
    }
}