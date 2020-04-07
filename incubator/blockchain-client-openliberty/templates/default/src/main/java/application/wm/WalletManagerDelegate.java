package application.wm;

import org.hyperledger.fabric.gateway.Wallet;

public class WalletManagerDelegate implements WalletManager {
    private Wallet theWallet;
    private static String WALLET_TYPE_ENV_VAR="WALLET_TYPE";
    private static String WALLET_TYPE_FILE_SYSTEM="FILE_SYSTEM";
    private static String WALLET_TYPE_IN_MEMORY="IN_MEMORY";

    private Wallet getCachedWallet() {
        return theWallet;
    }

    private void setCachedWallet(Wallet aWallet) {
        theWallet = aWallet;
    }
    private static WalletManager getWalletManager() {
        String walletType = System.getenv().get(WALLET_TYPE_ENV_VAR);
        if (walletType == WALLET_TYPE_FILE_SYSTEM) {
            return new FileSystemWallet();
        }

        if (walletType == WALLET_TYPE_IN_MEMORY) {
            return new InMemoryWallet();
        }
        return null;
    }
    @Override
    public synchronized Wallet getWallet() {
        Wallet wallet = getCachedWallet();
        if (wallet == null) {
            wallet = getWalletManager().getWallet();
            setCachedWallet(wallet);
        }
        return wallet;
    }

}