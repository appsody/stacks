package application.api;

import java.io.IOException;
import java.util.logging.Logger;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.PreMatching;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.ext.Provider;

import application.utils.ConnectionConfiguration;

@Provider
@PreMatching
public class IdentityMapperFilter implements ContainerRequestFilter {

    public static final Logger LOGGER = Logger.getLogger(IdentityMapperFilter.class.getName());

    @Override
    public void filter(ContainerRequestContext reqContext) throws IOException {

        String principal = extractPrincipal(reqContext);
        Response response = Response.status(Status.UNAUTHORIZED).build();
        
        if (principal == null) {
            // If the extractor couldn't determine the prinicipal
            // the request wasn't properly authenticated
            LOGGER.severe("Could not extract the authenticated subject from the incoming request.");
            reqContext.abortWith(response);
            return;
        }
        LOGGER.info("Principal: " + principal);
        // Logic here to map the extracted priciple to a fabric identity. 
        // We will simply pull the default idenity from the environment variable. 
        String identity = ConnectionConfiguration.getFabricDefaultIdentity();
        LOGGER.info("Identity: " + identity);
        if (identity == null) {
            // If the mapper cannot determine the fabric identity
            // the request is coming from an identity that cannot access the Fabric
            LOGGER.severe("Could not map the authenticated subject "+principal+" to a valid Fabric identity.");            
            reqContext.abortWith(response);
            return;
        }
        reqContext.getHeaders().add("X-FABRIC-IDENTITY", identity);
    }

    private String extractPrincipal(ContainerRequestContext reqContext) {
        /***************************************************************************
         * This method is meant to contain the logic 
         * that extracts the principal (or some other claim) from the authentication
         * token provided by the caller.
         * The default implementation returns a hardcoded string.
         * Actual implementations would be dependent on the actual authentication 
         * protocol used (OIDC, SAML, basic auth...)
         ***************************************************************************/
        return "default";
    }
}