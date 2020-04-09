package application.wm;

import org.hyperledger.fabric.gateway.Wallet;

public interface WalletManager {
    
    public Wallet getWallet(String identity);

}