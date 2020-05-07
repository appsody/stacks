package application.utils;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.io.IOException;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;
import org.json.JSONArray;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import application.utils.ConnectionConfiguration;

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
    public void testWalletCredentialsStringArrayInvalid() throws IdentityException {
        String arrayString = "[{type:FILE_SYSTEM,options:{path:/project/user-app/src/main/java/application/Org1}}]";
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(arrayString);

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentialsString array invalid
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsStringJsonInvalid() throws IdentityException {
        String arrayString = "{type:FILE_SYSTEM,options:{path:/project/user-app/src/main/java/application/Org1}}";
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(arrayString);

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentials json missing cert
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsCertMissing() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("msp_id", MSPID);
        id1.put("private_key", KEY);
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // wallet Credentials json cert empty
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsCertJsonEmpty() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", "");
        id1.put("msp_id", MSPID);
        id1.put("private_key", KEY);
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // wallet Credentials json cert not encoded
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsCertEncodeInvalid() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", "{875634");
        id1.put("msp_id", MSPID);
        id1.put("private_key", KEY);
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentials json missing private_key
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsPrivateKeyMissing() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", MSPID);
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentials json private_key empty
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsPrivateKeyJsonEmpty() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", MSPID);
        id1.put("private_key", "");
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentials json private_key not encoded
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsPrivateKeyEncodeInvalid() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", MSPID);
        id1.put("private_key", "{8765");
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentials json missing msp_id
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsMspMissing() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("private_key", KEY);
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // wallet Credentials json msp_id empty
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsMspEmpty() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", "");
        id1.put("private_key", KEY);
        id1.put("name", "id1");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // walletCredentials json missing name
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsNameMissing() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", MSPID);
        id1.put("private_key", KEY);

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // wallet Credentials json name invalid
    @Test(expected = IdentityException.class)
    public void testWalletCredentialsNameEmpty() throws IdentityException {
        JSONArray array = new JSONArray();

        //create identity1
        JSONObject id1 = new JSONObject();
        id1.put("cert", CERT);
        id1.put("msp_id", MSPID);
        id1.put("private_key", KEY);
        id1.put("name", "");

        array.put(id1);
        
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        imw.getWallet();

        fail("Expected Exception to be thrown");
    }

    // full good path
    @Test
    public void testWalletCredentialsGP() throws IdentityException, IOException {

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

        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getWalletCredentials()).thenReturn(array.toString());

        InMemoryWallet imw = new InMemoryWallet();
        Wallet resultWallet = imw.getWallet();

        assertNotNull(resultWallet);
        assertEquals(resultWallet.getAllLabels().size(), 2);
    }
}