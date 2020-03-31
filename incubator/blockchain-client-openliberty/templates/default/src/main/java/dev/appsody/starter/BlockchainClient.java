package dev.appsody.starter;

import java.io.IOException;

import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Wallet;

public class BlockchainClient {

    static private Gateway instance = null;

    public static Gateway getInstance() {
        // determine if we are using local fabric
        boolean isLocalhostURL = BlockchainConnectionUtil.hasLocalhostURLs();
        // isLocalhostURL = false;
        BlockchainConnectionUtil.setDiscoverAsLocalHost(isLocalhostURL);

        if (instance == null) {
            Wallet wallet = Wallet.createInMemoryWallet();
            Wallet.Identity identity = null;
            try {
                identity = Wallet.Identity.createIdentity(ConnectionConfiguration.getMspId(), ConnectionConfiguration.getCertificateRdr(),
                        ConnectionConfiguration.getPrivateKeyRdr());
            } catch (IOException e) {
                e.printStackTrace();
            }
            
            try {
              wallet.put(ConnectionConfiguration.getIdentity(), identity);
          } catch (IOException e) {
              e.printStackTrace();
          }
    
            // Configure the gateway connection used to access the network.
            Gateway.Builder builder = null;
            try {
                builder = Gateway.createBuilder().identity(wallet, ConnectionConfiguration.getIdentity())
                        .networkConfig(ConnectionConfiguration.getConnIS())
                        .discovery(true);
            } catch (IOException e) {
                e.printStackTrace();
            }
            
            // Create a gateway connection
            Gateway gateway = builder.connect();
            instance = gateway;
            return gateway;
        } else {
            return instance;
        }
    }

}