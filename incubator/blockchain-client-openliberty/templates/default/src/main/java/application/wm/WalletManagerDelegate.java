package application.wm;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;

public class WalletManagerDelegate implements WalletManager {
    private Wallet theWallet = null;
    private static final String WALLET_TYPE_FILE_SYSTEM="FILE_SYSTEM";
    private static final String WALLET_TYPE_IN_MEMORY="IN_MEMORY";

    private Wallet getCachedWallet() {
        return theWallet;
    }

    private void setCachedWallet(Wallet aWallet) {
        theWallet = aWallet;
    }

    private static WalletManager getWalletManager() throws IdentityException {
        WalletManager manager = null;
        JSONObject walletProfile = null;
        String walletProfileString = ConnectionConfiguration.getWalletProfile();
        
        if (walletProfileString == null || walletProfileString.isEmpty()) {
            throw new IdentityException("Wallet profile not found.");
        }

        try {
            walletProfile = new JSONObject(walletProfileString);
        } catch (JSONException e) {
            throw new IdentityException("Error parsing wallet profile.", e);
        }

        try {
            String walletType = walletProfile.getString("type");
            walletType = walletType.toUpperCase();
            if (walletType == null || walletType.isEmpty()) {
                throw new IdentityException("Invalid wallet type provided.");
            } 
            
            if (walletType.equals(WALLET_TYPE_FILE_SYSTEM)) {
                manager = new FileSystemWallet();
            }
            else if (walletType.equals(WALLET_TYPE_IN_MEMORY)) {
                manager = new InMemoryWallet();
            }
            else {
                throw new IdentityException("Invalid wallety type.");
            }
        } catch (JSONException e){
            throw new IdentityException("Exception parsing wallet type.");
        }
        return manager;
    }
    
    @Override
    public synchronized Wallet getWallet() throws IdentityException {
        Wallet wallet = getCachedWallet();
        if (wallet == null) {
            wallet = getWalletManager().getWallet();
            setCachedWallet(wallet);
        }
        return wallet;
    }
}