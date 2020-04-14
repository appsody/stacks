package application.wm;

import java.io.IOException;
import java.io.StringReader;
import java.util.Base64;

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

        JSONObject walletCredential;
        JSONArray walletCredentials;
        String walletCredentialsString = ConnectionConfiguration.getWalletCredentials();
     
        try {
            walletCredentials = new JSONArray(walletCredentialsString);
        } catch (JSONException excpt) { //TODO - should log and throw?
            return null;
        } 
        
        // process each identity
        for (Object walletCredentialObj: walletCredentials) {
            walletCredential = (JSONObject) walletCredentialObj;
            StringReader certificateRdr = null;
            StringReader privateKeyRdr = null;

            String certificate = walletCredential.getString("cert");
            if (certificate != null && !certificate.isEmpty()) {
                byte[] encoded = Base64.getDecoder().decode(certificate);
                certificateRdr = new StringReader(new String(encoded));
            }
            
            String privateKey = walletCredential.getString("private_key");
            if (privateKey != null && !privateKey.isEmpty()) {
                byte[] encoded = Base64.getDecoder().decode(privateKey);
                privateKeyRdr = new StringReader(new String(encoded));
            }

            String mspId = walletCredential.getString("msp_id");
            if (mspId == null || mspId.isEmpty()) {
                // todo handle missing case
            }

            String id = walletCredential.getString("name");
            if (id == null || id.isEmpty()) {
                // todo handle missing case
            }     

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