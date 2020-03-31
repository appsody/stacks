package dev.appsody.starter;

import javax.servlet.ServletContextEvent;
import javax.servlet.ServletContextListener;
import javax.servlet.annotation.WebListener;

@WebListener
public class ContextListener implements ServletContextListener {
    public void contextInitialized(ServletContextEvent sce){
        System.out.println("init succeeded");
        BlockchainClient.getInstance();
    }
}
