package application.wm;

import application.cm.ConnectionConfiguration;

import org.json.JSONObject;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;



/**
 * InMemoryWalletTest
 */

 // needed to use 2.0.7 mockito
 // did not work with jupiter Test import
 // appsody test did not run the junit tests with the jupiter dependency
 // alternative approach to powermock is using surefire environmentVariables https://stackoverflow.com/a/44594009

@RunWith(PowerMockRunner.class)
@PrepareForTest({ConnectionConfiguration.class})
public class InMemoryWalletTest {

    // walletCredentialsString null

    // walletCredentialsString empty

    // walletCredentialsString json invalid

    // walletCredentials json invalid

    // walletCredentials json missing
  
    // profile string valid

    // profile string empty
    @Test(expected = IdentityException.class)
    public void testProfileStringEmpty() throws IdentityException {
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn("");

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }

    // profile string null
    @Test(expected = IdentityException.class)
    public void testProfileStringNULL() throws IdentityException {
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(null);

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }

    // profile json valid

    // profile json invalid
    @Test(expected = IdentityException.class)
    public void testJsonInvalid() throws IdentityException {
        String json = "{type:FILE_SYSTEM,options:{path:/project/user-app/src/main/java/application/Org1}}";

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(json);

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }

    // options provided 

    // options missing
    @Test(expected = IdentityException.class)
    public void testOptionsMissing() throws IdentityException {
        JSONObject root = new JSONObject();
        root.put("type", "FILE_SYSTEM");
        String json = root.toString();

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(json);

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }

    // path missing
    @Test(expected = IdentityException.class)
    public void testPathMissing() throws IdentityException {
        JSONObject root = new JSONObject();
        root.put("type", "FILE_SYSTEM");
        JSONObject options = new JSONObject();
        root.put("options", options);
        String json = root.toString();

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(json);

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }

    // path invalid
    @Test(expected = IdentityException.class)
    public void testPathInvalid() throws IdentityException {
        JSONObject root = new JSONObject();
        root.put("type", "FILE_SYSTEM");
        JSONObject options = new JSONObject();
        options.put("path", "/somewhere");
        root.put("options", options);
        String json = root.toString();

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(json);

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }

    // path valid
    @Test(expected = IdentityException.class)
    public void testPathValid() throws IdentityException {
        JSONObject root = new JSONObject();
        root.put("type", "FILE_SYSTEM");
        JSONObject options = new JSONObject();
        options.put("path", "/somewhere");
        root.put("options", options);
        String json = root.toString();

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(json);

        FileSystemWallet fsw = new FileSystemWallet(); 
        fsw.getWallet();
    
        fail("Expected Exception to be thrown");
    }



}