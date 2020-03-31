package dev.appsody.starter;

import java.io.ByteArrayInputStream;
import java.io.StringReader;
import java.util.Base64;

public class ConnectionConfiguration {
    // local fabric examples:
    private static String conn = "";
    
    // local fabric example:
    private static String certificate = "";
    private static StringReader certificateRdr = new StringReader(certificate);
    
    // local fabri example:
    private static String privateKey = "";

    private static StringReader privateKeyRdr = new StringReader(privateKey);
    private static ByteArrayInputStream connIS = new ByteArrayInputStream(conn.getBytes());
    // private static String mspId = "org1msp";
    private static String mspId = "";
    private static String identity = "";
    private static String channel = "";
    private static String contract = "";

    // smart contract asset names:
    private static String getMethod = "readTnixaAsset";
    private static String putMethod = "updateTnixaAsset";
    private static String deleteMethod = "deleteTnixaAsset";
    private static String postMethod = "createTnixaAsset"; 

    // local env file needs to contain: 
    // CHANNEL
    // CONTRACT
    // MSPID 
    // IDENTITY
    // CONNECTION_PROFILE -> replace the ca and peer URLs with docker IPs if using local network
    // CERTIFICATE -> org1Admin cert, remove "\n"s base64 encode
    // PRIVATE_KEY -> org1Admin priv, base64 encode

    // sampple appsody run string:
    // appsody run -v --network <docker network ls> --docker-options "--env-file=<path to env file>"
    

    public static String getGetMethod(){
        return getMethod;
    } 

    public static String getPutMethod(){
        return putMethod;
    } 

    public static String getDeleteMethod(){
        return deleteMethod;
    } 

    public static String getPostMethod(){
        return postMethod;
    } 

    public static String getChannel(){
        String value = System.getenv("CHANNEL");
        if (value != null) {
            return value;
        }
        return channel;
    } 

    public static String getContract(){
        String value = System.getenv("CONTRACT");
        if (value != null) {
            return value;
        }
        return contract;
    } 

    public static String getConnectionProfile(){
        String value = System.getenv("CONNECTION_PROFILE");
        if (value != null) {
            return value;
        }
        return conn;
    } 
    public static StringReader getCertificateRdr() {
        String value = System.getenv("CERTIFICATE");
        if (value != null) {
            byte[] encoded = Base64.getDecoder().decode(value);
            return new StringReader(new String(encoded));
        }
        return certificateRdr;
    }

    public static StringReader getPrivateKeyRdr() {
        String value = System.getenv("PRIVATE_KEY");
        if (value != null) {
            byte[] encoded = Base64.getDecoder().decode(value);
            return new StringReader(new String(encoded));
        }
        return privateKeyRdr;
    }

    public static ByteArrayInputStream getConnIS() {
        String value = System.getenv("CONNECTION_PROFILE");
        if (value != null) {
            return new ByteArrayInputStream(value.getBytes());
        }
        return connIS;
    }

    public static String getMspId() {
        String value = System.getenv("MSPID");
        if (value != null) {
            return value;
        }
        return mspId;
    }

    public static String getIdentity() {
        String value = System.getenv("IDENTITY");
        if (value != null) {
            return value;
        }
        return identity;
    }

}