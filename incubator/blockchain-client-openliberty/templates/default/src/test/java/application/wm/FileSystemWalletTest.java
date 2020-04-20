package application.wm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNotNull;
import static org.junit.Assert.fail;

import java.io.IOException;
import java.io.StringReader;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;

import org.hyperledger.fabric.gateway.Wallet;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;
import org.json.JSONObject;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import application.cm.ConnectionConfiguration;

/**
 * FileSystemWalletTest
 */

 // needed to use 2.0.7 mockito
 // did not work with jupiter Test import
 // appsody test did not run the junit tests with the jupiter dependency
 // alternative approach to powermock is using surefire environmentVariables https://stackoverflow.com/a/44594009

@RunWith(PowerMockRunner.class)
@PrepareForTest({ConnectionConfiguration.class})
public class FileSystemWalletTest {

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

    // FileSystemWallet good path
    @Test
    public void testFileSystemWalletGP() throws IOException, IdentityException {
        String CERT = "LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUN2RENDQW1PZ0F3SUJBZ0lVYkx5OGJ2eHROeFBwTUxzYUI0Z1dVd1E0UzU4d0NnWUlLb1pJemowRUF3SXcKZnpFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ1RDa05oYkdsbWIzSnVhV0V4RmpBVUJnTlZCQWNURFZOaApiaUJHY21GdVkybHpZMjh4SHpBZEJnTlZCQW9URmtsdWRHVnlibVYwSUZkcFpHZGxkSE1zSUVsdVl5NHhEREFLCkJnTlZCQXNUQTFkWFZ6RVVNQklHQTFVRUF4TUxaWGhoYlhCc1pTNWpiMjB3SGhjTk1qQXdNekEyTWpJd05EQXcKV2hjTk1qRXdNekEyTWpJd09UQXdXakJoTVFzd0NRWURWUVFHRXdKVlV6RVhNQlVHQTFVRUNCTU9UbTl5ZEdnZwpRMkZ5YjJ4cGJtRXhGREFTQmdOVkJBb1RDMGg1Y0dWeWJHVmtaMlZ5TVE4d0RRWURWUVFMRXdaamJHbGxiblF4CkVqQVFCZ05WQkFNVENXOXlaekZCWkcxcGJqQlpNQk1HQnlxR1NNNDlBZ0VHQ0NxR1NNNDlBd0VIQTBJQUJCQ0YKcGg3REowSjRSN0VmeXBBRXd4c0FqMzdhVFZVQUs4QU9aSXNJSUM2aXliRXhkSVpTSWJJUllPV1ZqS29zWktBegplVjlvNnBlbllIMmlYYlJkc1NLamdkb3dnZGN3RGdZRFZSMFBBUUgvQkFRREFnZUFNQXdHQTFVZEV3RUIvd1FDCk1BQXdIUVlEVlIwT0JCWUVGTWc3Q0N5cjcvRFQ5MVhXdENXanF2MVRUNGJrTUI4R0ExVWRJd1FZTUJhQUZCZG4KUWoycW5vSS94TVVkbjF2RG1kRzFuRWdRTUJrR0ExVWRFUVFTTUJDQ0RtUnZZMnRsY2kxa1pYTnJkRzl3TUZ3RwpDQ29EQkFVR0J3Z0JCRkI3SW1GMGRISnpJanA3SW1obUxrRm1abWxzYVdGMGFXOXVJam9pSWl3aWFHWXVSVzV5CmIyeHNiV1Z1ZEVsRUlqb2liM0puTVVGa2JXbHVJaXdpYUdZdVZIbHdaU0k2SW1Oc2FXVnVkQ0o5ZlRBS0JnZ3EKaGtqT1BRUURBZ05IQURCRUFpQTRkRzFFYmtRM0d6SDVDTXFVdEZkUXJpWVNPc0RJUWxNVld3Ry8wTzdDRmdJZwpKeXF2NmxONUtmTURIYnNlVDFNeUVpSWhEZDhIc2NiTzF6b0N1cXRJbVdNPQotLS0tLUVORCBDRVJUSUZJQ0FURS0tLS0t";
        String KEY = "LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR0hBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJHMHdhd0lCQVFRZ0JRQlk0U0sxS2x1NVJsaWEKSk1DZU1NeW5IMDN0OUp0UW81SHg1aDRJa0txaFJBTkNBQVFRaGFZZXd5ZENlRWV4SDhxUUJNTWJBSTkrMmsxVgpBQ3ZBRG1TTENDQXVvc214TVhTR1VpR3lFV0RsbFl5cUxHU2dNM2xmYU9xWHAyQjlvbDIwWGJFaQotLS0tLUVORCBQUklWQVRFIEtFWS0tLS0t";
        StringReader certificateRdr = null;
        StringReader privateKeyRdr = null;
        Path path = null;
        Wallet testWallet = null; 
        try {
            byte[] encoded = Base64.getDecoder().decode(CERT);
            certificateRdr = new StringReader(new String(encoded));
            encoded = Base64.getDecoder().decode(KEY);
            privateKeyRdr = new StringReader(new String(encoded));
            path = Files.createTempDirectory("bctest");
            testWallet = Wallet.createFileSystemWallet(path);
            Wallet.Identity testIdentity = Wallet.Identity.createIdentity("msp1", certificateRdr, privateKeyRdr);
            testWallet.put("user", testIdentity);
            
            JSONObject root = new JSONObject();
            root.put("type", "FILE_SYSTEM");
            JSONObject options = new JSONObject();
            options.put("path", path.toString());
            root.put("options", options);
            String json = root.toString();

            PowerMockito.mockStatic(ConnectionConfiguration.class);
            PowerMockito.when(ConnectionConfiguration.getWalletProfile()).thenReturn(json);
    
            FileSystemWallet fsw = new FileSystemWallet(); 
            Wallet resultWallet = fsw.getWallet();

            assertNotNull(resultWallet);
            assertEquals(testWallet.getAllLabels(), resultWallet.getAllLabels());
 
        } finally {
            testWallet.remove("user");
            Files.deleteIfExists(path);
        }
    }

}