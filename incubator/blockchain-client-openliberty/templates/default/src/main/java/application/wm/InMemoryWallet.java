package application.wm;

import java.io.IOException;
import java.io.StringReader;
import java.util.Base64;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import application.cm.ConnectionConfiguration;

public class InMemoryWallet implements WalletManager {

    @Override
    public Wallet getWallet() throws IdentityException {
        Wallet wallet = Wallet.createInMemoryWallet();
        Wallet.Identity identity = null;

        String walletCredentialsString = ConnectionConfiguration.getWalletCredentials();
        if (walletCredentialsString == null || walletCredentialsString.isEmpty()) {
            throw new IdentityException("Wallet credentials not found.");
        }
        JSONArray walletCredentials = null;
     
        // parse wallet identities
        try {
            walletCredentials = new JSONArray(walletCredentialsString);
        } catch (JSONException e) {
            throw new IdentityException("Error parsing wallet credentials.", e);
        } 
        
        // process each identity
        for (Object walletCredentialObj: walletCredentials) {
            StringReader certificateRdr = null;
            StringReader privateKeyRdr = null;
            String mspId = null;
            String id = null;

            try {
                JSONObject walletCredential = (JSONObject) walletCredentialObj;

                String certificate = walletCredential.getString("cert");
                if (certificate != null && !certificate.isEmpty()) {
                    byte[] encoded = Base64.getDecoder().decode(certificate);
                    certificateRdr = new StringReader(new String(encoded));
                } else {
                    throw new IdentityException("Invalid certificate provided.");
                }
                
                String privateKey = walletCredential.getString("private_key");
                if (privateKey != null && !privateKey.isEmpty()) {
                    byte[] encoded = Base64.getDecoder().decode(privateKey);
                    privateKeyRdr = new StringReader(new String(encoded));
                } else {
                    throw new IdentityException("Invalid private key provided.");
                }

                mspId = walletCredential.getString("msp_id");
                if (mspId == null || mspId.isEmpty()) {
                    throw new IdentityException("Invalid msp id provided.");
                }

                id = walletCredential.getString("name");
                if (id == null || id.isEmpty()) {
                    throw new IdentityException("Invalid id provided");
                } 
            } catch (JSONException | IllegalArgumentException | ClassCastException  e) {
                throw new IdentityException("Exception processing identity.", e);
            }

            try {
                identity = Wallet.Identity.createIdentity(mspId, certificateRdr, privateKeyRdr);
                wallet.put(id, identity);
            } catch (IOException e) {
                throw new IdentityException("Exception creating wallet identity.", e);
            }
        }
        return wallet;
    }
}