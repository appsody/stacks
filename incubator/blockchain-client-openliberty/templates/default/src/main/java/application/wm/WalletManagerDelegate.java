package application.wm;

import org.hyperledger.fabric.gateway.Wallet;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;

public class WalletManagerDelegate implements WalletManager {
    private Wallet theWallet;
    private static String WALLET_TYPE_FILE_SYSTEM="FILE_SYSTEM";
    private static String WALLET_TYPE_IN_MEMORY="IN_MEMORY";

    private Wallet getCachedWallet() {
        return theWallet;
    }

    private void setCachedWallet(Wallet aWallet) {
        theWallet = aWallet;
    }
    private static WalletManager getWalletManager() {
       
        // TODO - Util function to retrieve/validate these JSONObjects from strings
        JSONObject walletProfile;
        String walletProfileString = ConnectionConfiguration.getWalletProfile();
        try {
            walletProfile = new JSONObject(walletProfileString);
        } catch (JSONException excpt) { //should log and throw?
            return null;
        }          
        String walletType = walletProfile.getString("type");
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