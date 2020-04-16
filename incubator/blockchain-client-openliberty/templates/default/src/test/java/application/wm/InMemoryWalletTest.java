package application.wm;

import application.cm.ConnectionConfiguration;

import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.Test;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.assertNull;
import static org.junit.Assert.fail;

import java.io.IOException;

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
// alternative approach to powermock is using surefire environmentVariables
// https://stackoverflow.com/a/44594009

@RunWith(PowerMockRunner.class)
@PrepareForTest({ ConnectionConfiguration.class })
public class InMemoryWalletTest {

    private static String CERT = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN2RENDQW1PZ0F3SUJBZ0lVYkx5OGJ2eHROeFBwTUxzYUI0Z1dVd1E0UzU4d0NnWUlLb1pJemowRUF3SXcKZnpFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ1RDa05oYkdsbWIzSnVhV0V4RmpBVUJnTlZCQWNURFZOaApiaUJHY21GdVkybHpZMjh4SHpBZEJnTlZCQW9URmtsdWRHVnlibVYwSUZkcFpHZGxkSE1zSUVsdVl5NHhEREFLCkJnTlZCQXNUQTFkWFZ6RVVNQklHQTFVRUF4TUxaWGhoYlhCc1pTNWpiMjB3SGhjTk1qQXdNekEyTWpJd05EQXcKV2hjTk1qRXdNekEyTWpJd09UQXdXakJoTVFzd0NRWURWUVFHRXdKVlV6RVhNQlVHQTFVRUNCTU9UbTl5ZEdnZwpRMkZ5YjJ4cGJtRXhGREFTQmdOVkJBb1RDMGg1Y0dWeWJHVmtaMlZ5TVE4d0RRWURWUVFMRXdaamJHbGxiblF4CkVqQVFCZ05WQkFNVENXOXlaekZCWkcxcGJqQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJCQ0YKcGg3REowSjRSN0VmeXBBRXd4c0FqMzdhVFZVQUs4QU9aSXNJSUM2aXliRXhkSVpTSWJJUllPV1ZqS29zWktBegplVjlvNnBlbllIMmlYYlJkc1NLamdkb3dnZGN3RGdZRFZSMFBBUUgvQkFRREFnZUFNQXdHQTFVZEV3RUIvd1FDCk1BQXdIUVlEVlIwT0JCWUVGTWc3Q0N5cjcvRFQ5MVhXdENXanF2MVRUNGJrTUI4R0ExVWRJd1FZTUJhQUZCZG4KUWoycW5vSS94TVVkbjF2RG1kRzFuRWdRTUJrR0ExVWRFUVFTTUJDQ0RtUnZZMnRsY2kxa1pYTnJkRzl3TUZ3RwpDQ29EQkFVR0J3Z0JCRkI3SW1GMGRISnpJanA3SW1obUxrRm1abWxzYVdGMGFXOXVJam9pSWl3aWFHWXVSVzV5CmIyeHNiV1Z1ZEVsRUlqb2liM0puTVVGa2JXbHVJaXdpYUdZdVZIbHdaU0k2SW1Oc2FXVnVkQ0o5ZlRBS0JnZ3EKaGtqT1BRUURBZ05IQURCRUFpQTRkRzFFYmtRM0d6SDVDTXFVdEZkUXJpWVNPc0RJUWxNVld3Ry8wTzdDRmdJZwpKeXF2NmxONUtmTURIYnNlVDFNeUVpSWhEZDhIc2NiTzF6b0N1cXRJbVdNPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0t";
    private static String KEY = "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR0hBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJHMHdhd0lCQVFRZ0JRQlk0U0sxS2x1NVJsaWEKSk1DZU1NeW5IMDN0OUp0UW81SHg1aDRJa0txaFJBTkNBQVFRaGFZZXd5ZENlRWV4SDhxUUJNTWJBSTkrMmsxVgpBQ3ZBRG1TTENDQXVvc214TVhTR1VpR3lFV0RsbFl5cUxHU2dNM2xmYU9xWHAyQjlvbDIwWGJFaQotLS0tLUVORCBQUklWQVRFIEtFWS0tLS0t";
    private static String MSPID = "Org1MSP";

    // walletCredentialsString null
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsStringEmpty() throws IdentityException {
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn("");

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentialsString empty
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsStringNull() throws IdentityException {
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(null);

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentialsString json array invalid
    @Test(expected = IdentityException.class)
    public void tnixa() throws IdentityException {
        String arrayString = "[{type:FILE_SYSTEM,options:{path:/project/user-app/src/main/java/application/Org1}}]";
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(arrayString);

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    @Test
    public void testWalletCredentialsStringJsonInvalid() throws IdentityException, IOException {

        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", MSPID);
        id1.put("private_key", KEY);
        id1.put("name", "id1");

        //create identity2
        JSONObject id2 = new JSONObject();
        id2.put("cert", CERT);
        id2.put("msp_id", MSPID);
        id2.put("private_key", KEY);
        id2.put("name", "id2");

        array.put(id1);
        array.put(id2);

        System.out.println(array);

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        Wallet resultWallet = imw.getWallet();

        assertNotNull(resultWallet);
        assertEquals(resultWallet.getAllLabels().size(), 2);
    }

    // walletCredentials json invalid

    // walletCredentials json missing cert

    // wallet Credentials json cert invalid

    // wallet Credentials json cert not encoded

    // walletCredentials json missing private_key

    // walletCredentials json private_key invalid

    // walletCredentials json private_key not encoded

    // walletCredentials json missing msp_id

    // wallet Credentials json msp_id invalid

    // walletCredentials json missing name

    // wallet Credentials json name invalid

    // something to cause the identity to fail, not sure how to do that ??

    // something to test the array, maybe the first value in the array is good but the second is bad json?






  
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