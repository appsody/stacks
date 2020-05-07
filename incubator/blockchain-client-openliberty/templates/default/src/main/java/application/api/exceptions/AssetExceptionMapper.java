package application.api.exceptions;

import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.ext.ExceptionMapper;
import javax.ws.rs.ext.Provider;

import org.hyperledger.fabric.gateway.GatewayException;
import org.hyperledger.fabric_ca.sdk.exception.IdentityException;

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
      if (exception instanceof GatewayException) {
        response = new ExceptionResponse(exception.getMessage());
        return Response.status(Status.BAD_REQUEST).entity(response).build();
      }
      if (exception instanceof IdentityException) {
        response = new ExceptionResponse(exception.getMessage());
        return Response.status(Status.BAD_REQUEST).entity(response).build();
      }

      return Response.serverError().entity(exception).build();
      
    }
}