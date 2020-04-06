package application.wm;

public class WalletManagerDelegate {
    private static String WALLET_TYPE_ENV_VAR="WALLET_TYPE";
    private static String WALLET_TYPE_FILE_SYSTEM="FILE_SYSTEM";


    public static WalletManager getWalletManager() {
        String walletType = System.getenv().get(WALLET_TYPE_ENV_VAR);
        if (walletType == WALLET_TYPE_FILE_SYSTEM) {
            return new FileSystemWallet();
        }
        return null;
    }
}