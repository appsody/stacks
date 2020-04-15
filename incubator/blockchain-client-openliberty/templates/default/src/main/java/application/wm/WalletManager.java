package application.wm;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;

public interface WalletManager {
    
    public Wallet getWallet() throws IdentityException;

}