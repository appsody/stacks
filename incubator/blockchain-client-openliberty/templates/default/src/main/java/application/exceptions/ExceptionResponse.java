package application.exceptions;

public class ExceptionResponse {
    private String message = null;
     
    public ExceptionResponse(String message) {
      super();
      this.message = message;
    }
     
    public ExceptionResponse() {
     
    }
    // Getters and Setters

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
  }