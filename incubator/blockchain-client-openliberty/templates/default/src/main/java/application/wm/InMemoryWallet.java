package application.wm;

import org.hyperledger.fabric.gateway.Wallet;


public class InMemoryWallet implements WalletManager {
    static final String WALLET_PATH_ENV_VAR="WALLET_PATH";
    @Override
    public Wallet getWallet() {
        return null;

    }
}