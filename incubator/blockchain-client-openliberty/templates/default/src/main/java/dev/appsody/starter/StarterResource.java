package dev.appsody.starter;

import javax.ws.rs.GET;
import javax.ws.rs.Path;
import application.model.Asset;

@Path("/resource")
public class StarterResource {

    @GET
    public String getRequest() {
        Asset asset = new Asset();
        asset.setAssetName("TEST");
        return "StarterResource: "+asset.getAssetName();
    }
}
