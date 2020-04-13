package application.cm;


public class ConnectionConfiguration {

    private static final String FABRIC_CHANNEL_ENV_VAR = "FABRIC_CHANNEL";
    private static final String FABRIC_CONTRACT_ENV_VAR = "FABRIC_CONTRACT";
    private static final String FABRIC_CONN_PROFILE_ENV_VAR = "FABRIC_CONNECTION_PROFILE";
    private static final String FABRIC_WALLET_PROFILE_ENV_VAR = "FABRIC_WALLET_PROFILE";


    public static String getChannel() {
        return System.getenv(FABRIC_CHANNEL_ENV_VAR);
    } 

    public static String getContractId() {
        return System.getenv(FABRIC_CONTRACT_ENV_VAR);
    } 

    public static String getConnectionProfile() {
        return System.getenv(FABRIC_CONN_PROFILE_ENV_VAR);
    }

    public static String getWalletProfile() {
        return System.getenv(FABRIC_WALLET_PROFILE_ENV_VAR);
    }
}