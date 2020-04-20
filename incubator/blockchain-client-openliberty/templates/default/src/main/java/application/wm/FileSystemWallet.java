package application.wm;

import java.io.IOException;
import java.nio.file.FileSystems;
import java.nio.file.InvalidPathException;
import java.nio.file.Path;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;

public class FileSystemWallet implements WalletManager {

    @Override
    public Wallet getWallet() throws IdentityException {
        Wallet wallet = null;
        String walletPath = null;
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
            JSONObject options = walletProfile.getJSONObject("options");
            walletPath = options.getString("path"); 
            if (walletPath == null || walletPath.isEmpty()) {
                throw new IdentityException("Invalid wallet path provided.");
            }
        } catch (JSONException e) {
            throw new IdentityException("Exception parsing wallet options.");
        }

        try {
            Path basePath = FileSystems.getDefault().getPath(walletPath);
            wallet = Wallet.createFileSystemWallet(basePath);
            if (wallet == null) {
                throw new IdentityException("Invalid wallet provided.");
            }
        } catch (IOException | InvalidPathException e) {
            throw new IdentityException("Exception processing wallet path.");
        }
        return wallet;
    }
}