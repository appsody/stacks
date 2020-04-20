package application.cm;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertNull;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

/**
 * ConnectionConfigurationTest
 */

 // needed to use 2.0.7 mockito
 // did not work with jupiter Test import
 // appsody test did not run the junit tests with the jupiter dependency
 // alternative approach to powermock is using surefire environmentVariables https://stackoverflow.com/a/44594009

@RunWith(PowerMockRunner.class)
@PrepareForTest({System.class, ConnectionConfiguration.class})
public class ConnectionConfigurationTest {
  
    // channel tests
    @Test
    public void testGetChannel() {
        String TEST_CHANNEL_GP = "testchannel";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CHANNEL")).thenReturn(TEST_CHANNEL_GP);
        String channel = ConnectionConfiguration.getChannel();
        assertEquals(TEST_CHANNEL_GP, channel);  
    }

    @Test
    public void testGetChannelBP() {
        String TEST_CHANNEL_BP = "";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CHANNEL")).thenReturn(TEST_CHANNEL_BP);
        String channel = ConnectionConfiguration.getChannel();
        assertEquals(TEST_CHANNEL_BP, channel);  
    }

    @Test
    public void testGetChannelNULL() {
        String TEST_CHANNEL_NULL = null;
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CHANNEL")).thenReturn(TEST_CHANNEL_NULL);
        String channel = ConnectionConfiguration.getChannel();
        assertNull(channel);
    }

    //contract tests
    @Test
    public void testGetContractID() {
        String TEST_CONTRACT_GP = "testcontract";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CONTRACT")).thenReturn(TEST_CONTRACT_GP);
        String contract = ConnectionConfiguration.getContractId();
        assertEquals(TEST_CONTRACT_GP, contract);  
    }

    @Test
    public void testGetContractIDBP() {
        String TEST_CONTRACT_BP = "";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CONTRACT")).thenReturn(TEST_CONTRACT_BP);
        String contract = ConnectionConfiguration.getContractId();
        assertEquals(TEST_CONTRACT_BP, contract);  
    }

    @Test
    public void testGetContractIDNULL() {
        String TEST_CONTRACT_NULL = null;
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CONTRACT")).thenReturn(TEST_CONTRACT_NULL);
        String contract = ConnectionConfiguration.getContractId();
        assertNull(contract);
    }

    // connection profile tests
    @Test
    public void testGetConnectionProfile() {
        String TEST_CONNECTION_PROFILE_GP = "testprofile";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CONNECTION_PROFILE")).thenReturn(TEST_CONNECTION_PROFILE_GP);
        String connection = ConnectionConfiguration.getConnectionProfile();
        assertEquals(TEST_CONNECTION_PROFILE_GP, connection);  
    }

    @Test
    public void testGetConnectionProfileBP() {
        String TEST_CONNECTION_PROFILE_BP = "";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CONNECTION_PROFILE")).thenReturn(TEST_CONNECTION_PROFILE_BP);
        String connection = ConnectionConfiguration.getConnectionProfile();
        assertEquals(TEST_CONNECTION_PROFILE_BP, connection);  
    }

    @Test
    public void testGetConnectionProfileNULL() {
        String TEST_CONNECTION_PROFILE_NULL = null;
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_CONNECTION_PROFILE")).thenReturn(TEST_CONNECTION_PROFILE_NULL);
        String connection = ConnectionConfiguration.getConnectionProfile();
        assertNull(connection);
    }

    // wallet profile tests
    @Test
    public void testGetWalletProfile() {
        String TEST_WALLET_PROFILE_GP = "testprofile";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_WALLET_PROFILE")).thenReturn(TEST_WALLET_PROFILE_GP);
        String wallet = ConnectionConfiguration.getWalletProfile();
        assertEquals(TEST_WALLET_PROFILE_GP, wallet);  
    }

    @Test
    public void testGetWalletProfileBP() {
        String TEST_CONNECTION_PROFILE_BP = "";
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_WALLET_PROFILE")).thenReturn(TEST_CONNECTION_PROFILE_BP);
        String wallet = ConnectionConfiguration.getWalletProfile();
        assertEquals(TEST_CONNECTION_PROFILE_BP, wallet);  
    }

    @Test
    public void testGetWalletProfileNULL() {
        String TEST_CONNECTION_PROFILE_NULL = null;
        PowerMockito.mockStatic(System.class);
        PowerMockito.when(System.getenv("FABRIC_WALLET_PROFILE")).thenReturn(TEST_CONNECTION_PROFILE_NULL);
        String wallet = ConnectionConfiguration.getWalletProfile();
        assertNull(wallet);
    }
}