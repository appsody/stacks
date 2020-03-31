package dev.appsody.starter.exceptions;

public class AssetNotFoundException extends RuntimeException {
    private static final long serialVersionUID = 1L;
 
    public AssetNotFoundException(String message) {
        super(message);
    }
}