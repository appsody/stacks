package application.api;

import java.io.IOException;
import java.util.logging.Logger;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.PreMatching;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Response.Status;
import javax.ws.rs.ext.Provider;

import application.auth.DefaultIdentityMapper;
import application.auth.IdentityMapper;

@Provider
@PreMatching
public class IdentityExtractorFilter implements ContainerRequestFilter {

    public static final Logger LOGGER = Logger.getLogger(IdentityExtractorFilter.class.getName());

    @Override
    public void filter(ContainerRequestContext reqContext) throws IOException {

        String principal = extractPrincipal(reqContext);
        Response response = Response.status(Status.UNAUTHORIZED).build();
        
        if (principal == null) {
            // If the extractor couldn't determine the prinicipal
            // the request wasn't properly authenticated
            LOGGER.severe("Could not extract the authenticated subject from the incoming request.");
            reqContext.abortWith(response);
        }
        LOGGER.info("Principal: " + principal);
        IdentityMapper mapper = new DefaultIdentityMapper();
        String identity = mapper.getFabricIdentity(principal);
        LOGGER.info("Identity: " + identity);
        if (identity == null) {
            // If the mapper cannot determine the fabric identity
            // the request is coming from an identity that cannot access the Fabric
            LOGGER.severe("Could not map the authenticated subject "+principal+" to a valid Fabric identity.");            
            reqContext.abortWith(response);
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