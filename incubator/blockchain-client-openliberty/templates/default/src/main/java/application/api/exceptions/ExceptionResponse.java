package application.api.exceptions;

public class ExceptionResponse {
    private String message = null;
     
    public ExceptionResponse(String message) {
      super();
      this.message = message;
    }
     
    public ExceptionResponse() {
    }

    public String getMessage() {
        return message;
    }

    public void setMessage(String message) {
        this.message = message;
    }
  }