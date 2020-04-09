package application.exceptions;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

@Provider
public class AssetExceptionMapper implements ExceptionMapper<Throwable> {
   
  @Override
  public Response toResponse(Throwable exception) {
      ExceptionResponse response = null;
      if (exception instanceof AssetNotFoundException){
        response = new ExceptionResponse(exception.getMessage());
        return Response.status(Status.NOT_FOUND).entity(response).build();
      }
      if (exception instanceof AssetException){
        response = new ExceptionResponse(exception.getMessage());
        return Response.status(Status.BAD_REQUEST).entity(response).build();
      }

      return Response.serverError().entity(exception).build();
      
    }
}