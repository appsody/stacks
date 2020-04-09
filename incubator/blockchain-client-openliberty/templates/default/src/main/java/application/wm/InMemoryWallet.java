package application.wm;

import java.io.IOException;
import java.io.StringReader;

import org.hyperledger.fabric.gateway.Wallet;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;


public class InMemoryWallet implements WalletManager {

    @Override
    public Wallet getWallet(String id) {
        Wallet wallet = Wallet.createInMemoryWallet();
        Wallet.Identity identity = null;
        // TODO - Util function to retrieve/validate these JSONObjects from strings
        JSONObject walletProfile;
        String walletProfileString = ConnectionConfiguration.getWalletProfile();
        try {
            walletProfile = new JSONObject(walletProfileString);
        } catch (JSONException excpt) { //should log and throw?
            return null;
        }    
        //TODO - need to add checking for nulls, excpt handling
        String mspId = walletProfile.getString("msp_id");
        String certificate = walletProfile.getJSONObject("keys").getString("certificate");
        String privateKey = walletProfile.getJSONObject("keys").getString("private_key");

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
    return wallet;
    }
}