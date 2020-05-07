
package application.api;

import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.times;
import static org.mockito.Mockito.verify;

import java.io.IOException;

import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.core.Response;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.mockito.ArgumentCaptor;
import org.mockito.Mockito;
import org.powermock.api.mockito.PowerMockito;
import org.powermock.core.classloader.annotations.PrepareForTest;
import org.powermock.modules.junit4.PowerMockRunner;

import application.utils.ConnectionConfiguration;

/**
 * IdentityMapperFilterTest
 */
@RunWith(PowerMockRunner.class)
@PrepareForTest({ConnectionConfiguration.class, IdentityMapperFilter.class})
 public class IdentityMapperFilterTest {


    @Test
    public void testFilter() throws IOException  {   
        ContainerRequestContext reqContext = mock(ContainerRequestContext.class, Mockito.RETURNS_DEEP_STUBS);
        IdentityMapperFilter filter = new IdentityMapperFilter();

        // The default identity is derived form the env variable. 
        PowerMockito.mockStatic(ConnectionConfiguration.class);
        PowerMockito.when(ConnectionConfiguration.getFabricDefaultIdentity()).thenReturn("admin");

        filter.filter(reqContext);
        verify(reqContext, times(1)).getHeaders();
    }


    @Test
    public void testFilterNullIdentity() throws IOException  {   
        ContainerRequestContext reqContext = mock(ContainerRequestContext.class);
        IdentityMapperFilter filter = new IdentityMapperFilter();

        ArgumentCaptor<Response> argumentCaptor = ArgumentCaptor.forClass(Response.class);
        filter.filter(reqContext);
        verify(reqContext).abortWith(argumentCaptor.capture());

        Response response = argumentCaptor.getValue();
        System.out.println(response);
    }

    @Test
    public void testFilterNullPrinciple() throws Exception {
        ContainerRequestContext reqContext = mock(ContainerRequestContext.class);
        IdentityMapperFilter filter = PowerMockito.spy(new IdentityMapperFilter());
         PowerMockito.when(filter, "extractPrincipal", reqContext).thenReturn(null);

        ArgumentCaptor<Response> argumentCaptor = ArgumentCaptor.forClass(Response.class);
        filter.filter(reqContext);
        verify(reqContext).abortWith(argumentCaptor.capture());

        Response response = argumentCaptor.getValue();
        System.out.println(response);
    }  
}