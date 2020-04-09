package application.wm;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.Path;

import org.apache.http.config.ConnectionConfig;
import org.hyperledger.fabric.gateway.Wallet;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;



public class FileSystemWallet implements WalletManager {

    @Override
    public Wallet getWallet(String id) {
        //Note: FileSystemWallet makes no use of the id parm
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

        walletPath = walletProfile.getString("path");
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