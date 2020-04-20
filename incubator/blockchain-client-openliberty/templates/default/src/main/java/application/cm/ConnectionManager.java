package application.cm;

import java.io.ByteArrayInputStream;
import java.io.IOException;
import java.util.HashMap;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.GatewayException;
import org.hyperledger.fabric.gateway.GatewayRuntimeException;
import org.hyperledger.fabric.gateway.Network;
import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;

import application.wm.WalletManagerDelegate;

public class ConnectionManager {

    private static HashMap<String, Gateway> gateways = new HashMap<String, Gateway>();

    private static Gateway getGateway(String fabricId) throws IdentityException, GatewayException {
        Gateway gateway = null;

        synchronized (gateways) {
            gateway = gateways.get(fabricId);
            Gateway.Builder builder = null;

            if (gateway == null) {
                ByteArrayInputStream connProfileIS = new ByteArrayInputStream(ConnectionConfiguration.getConnectionProfile().getBytes());
                WalletManagerDelegate wmd = new WalletManagerDelegate();
                Wallet wallet = wmd.getWallet();
                
                try {
                    builder = Gateway.createBuilder().identity(wallet, fabricId).networkConfig(connProfileIS).discovery(true);
                } catch (IOException e) {
                    throw new GatewayException("Error constructing gateway.", e);
                }
            
                gateway = builder.connect();
                gateways.put(fabricId, gateway);
            } 
        }
        return gateway;
    }

    public static Contract getContract(String fabricId) throws IdentityException, GatewayException {
        String channel = ConnectionConfiguration.getChannel();
        String chaincodeId = ConnectionConfiguration.getContractId();

        Gateway gateway = getGateway(fabricId);
        Network network = null;
        Contract contract = null;
        try {
            network = gateway.getNetwork(channel);
            contract = network.getContract(chaincodeId);
        } catch (GatewayRuntimeException e) {
            throw new GatewayException("Error retrieving contract.", e);
        }
        return contract;
    }
}