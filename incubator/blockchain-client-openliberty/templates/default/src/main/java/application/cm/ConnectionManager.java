package application.cm;
//Creates the Gateway from an Identity (now in BlockchainClient.java)

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.HashMap;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Wallet;


import application.wm.WalletManagerDelegate;

public class ConnectionManager {

    private static HashMap<String, Gateway> gateways;
    private static String syncHelper = "Helper";

    public ConnectionManager() {
        synchronized (syncHelper) {
            if (gateways == null) {
                gateways = new HashMap<String, Gateway>();
            }
        }
    }

    public Gateway getGateway(String id) {
        Gateway gateway;

        synchronized (gateways) {
            gateway = gateways.get(id);
            Gateway.Builder builder;
            if (gateway == null) { // Call wallet manager here
                ByteArrayInputStream connProfileIS = new ByteArrayInputStream(
                        ConnectionConfiguration.getConnectionProfile().getBytes());
                WalletManagerDelegate wmd = new WalletManagerDelegate();
                Wallet wallet = wmd.getWallet(id);
                try {
                    builder = Gateway.createBuilder().identity(wallet, id).networkConfig(connProfileIS).discovery(true);
                } catch (IOException e) {
                    // TODO Auto-generated catch block
                    e.printStackTrace();
                    return null;
                }
                //construct the gateway
                gateway = builder.connect();
                gateways.put(id, gateway);
            } 
        }
        return gateway;
    }

    public Contract getContract(String identityId) {
        
        String channel = ConnectionConfiguration.getChannel();

        return getGateway(identityId).getNetwork(channel).getContract(ConnectionConfiguration.getContractId());
    }
}