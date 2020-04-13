package application.exceptions;

public class AssetException extends RuntimeException {
    private static final long serialVersionUID = 1L;
 
    public AssetException(String message) {
        super(message);
    }
}