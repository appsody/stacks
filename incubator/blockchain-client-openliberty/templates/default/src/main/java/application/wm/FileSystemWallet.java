package application.wm;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;

import org.hyperledger.fabric.gateway.Wallet;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;

public class FileSystemWallet implements WalletManager {

    @Override
    public Wallet getWallet() {
        Wallet wallet;
        String walletPath;
        JSONObject walletProfile;
        // TODO - Util function to retrieve/validate these JSONObjects from strings
        String walletProfileString = ConnectionConfiguration.getWalletProfile();
        
        try {
            walletProfile = new JSONObject(walletProfileString);
        } catch (JSONException excpt) { //should log and throw?
            return null;
        }

        JSONObject options = walletProfile.getJSONObject("options");
        walletPath = options.getString("path"); 

        //TODO should log here
        if (walletPath == null) {
            return null; // log and throw
        }
        try {
            Path basePath = FileSystems.getDefault().getPath(walletPath);
            wallet = Wallet.createFileSystemWallet(basePath);
            return wallet;
        } catch (IOException excpt) {
            return null;
        }
    }
}