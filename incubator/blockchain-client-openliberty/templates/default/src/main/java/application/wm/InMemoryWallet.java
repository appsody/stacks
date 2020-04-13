package application.wm;

import java.io.IOException;
import java.io.StringReader;

import org.hyperledger.fabric.gateway.Wallet;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;


public class InMemoryWallet implements WalletManager {

    @Override
    public Wallet getWallet() {
        Wallet wallet = Wallet.createInMemoryWallet();
        Wallet.Identity identity = null;
        // TODO - Util function to retrieve/validate these JSONObjects from strings
    //    JSONObject walletProfile;
        JSONObject walletCredential;
        JSONArray walletCredentials;
        String walletProfileString = ConnectionConfiguration.getWalletProfile();
        String walletCredentialsString = ConnectionConfiguration.getWalletCredentials();
    //    try {
    //        walletProfile = new JSONObject(walletProfileString);
    //    } catch (JSONException excpt) { //TODO - should log and throw?
    //        return null;
    //    }    
        try {
            walletCredentials = new JSONArray(walletCredentialsString);
        } catch (JSONException excpt) { //TODO - should log and throw?
            return null;
        }    
        for (Object walletCredentialObj: walletCredentials) {
            walletCredential = (JSONObject) walletCredentialObj;
            String certificate = walletCredential.getString("cert");
            String privateKey = walletCredential.getString("private_key");
            String mspId = walletCredential.getString("mspId");
            String id = walletCredential.getString("name");

            StringReader certificateRdr = new StringReader(certificate);
            StringReader privateKeyRdr = new StringReader(privateKey);
    //TODO - proper exception handling
            try {
                identity = Wallet.Identity.createIdentity(mspId, certificateRdr, privateKeyRdr);
            } catch (IOException e) {
                e.printStackTrace();
            }
            
            try {
                wallet.put(id, identity);
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        return wallet;
    }
}