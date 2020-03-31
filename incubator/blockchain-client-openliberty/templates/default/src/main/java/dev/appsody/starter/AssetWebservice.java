package dev.appsody.starter;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeoutException;

import javax.ws.rs.Consumes;
import javax.ws.rs.DELETE;
import javax.ws.rs.GET;
import javax.ws.rs.POST;
import javax.ws.rs.PUT;
import javax.ws.rs.Path;
import javax.ws.rs.PathParam;
import javax.ws.rs.Produces;
import javax.ws.rs.core.Response;

import org.eclipse.microprofile.openapi.annotations.ExternalDocumentation;
import org.eclipse.microprofile.openapi.annotations.OpenAPIDefinition;
import org.eclipse.microprofile.openapi.annotations.Operation;
import org.eclipse.microprofile.openapi.annotations.info.Contact;
import org.eclipse.microprofile.openapi.annotations.info.Info;
import org.eclipse.microprofile.openapi.annotations.media.Content;
import org.eclipse.microprofile.openapi.annotations.media.Schema;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponse;
import org.eclipse.microprofile.openapi.annotations.responses.APIResponses;
import org.eclipse.microprofile.openapi.annotations.tags.Tag;
import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.ContractException;
import org.hyperledger.fabric.gateway.Gateway;
import org.hyperledger.fabric.gateway.Network;

import dev.appsody.starter.exceptions.AssetException;
import dev.appsody.starter.exceptions.AssetNotFoundException;

@Path("/assets")
@OpenAPIDefinition(info = @Info(title = "Blockchain Asset Web Service", version = "0.1", description = "Restful Web Service for blockchain transactions.", contact = @Contact(url = "https://www.ibm.com/blockchain")), externalDocs = @ExternalDocumentation(description = "https://www.ibm.com/blockchain", url = "https://www.ibm.com/blockchain"))
public class AssetWebservice {

    @GET
    @Path("/{id}")
    @Produces("application/json")
    @APIResponses(value = {
        @APIResponse(responseCode = "200", description = "Asset", content = @Content(mediaType = "application/json", schema = @Schema(implementation = Asset.class))),
        @APIResponse(responseCode = "400", description = "Error reading asset", content = @Content(mediaType = "application/json")),    
        @APIResponse(responseCode = "404", description = "Asset not found", content = @Content(mediaType = "application/json")) }) 
    @Operation(summary = "Retrieve asset from the blockchain", description = "Retrieves the asset from the blockchain.")
    @Tag(name = "Assets")
    public Response getAsset(@PathParam("id") String id) throws AssetNotFoundException, AssetException {
        Gateway gateway = BlockchainClient.getInstance();

        // Obtain a smart contract deployed on the network.
        Network network = gateway.getNetwork(ConnectionConfiguration.getChannel());
        Contract contract = network.getContract(ConnectionConfiguration.getContract());

        // Submit transactions to read state on the ledger
        byte[] result = null;
        try {
            result = contract.submitTransaction(ConnectionConfiguration.getGetMethod(), id);
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }

        return Response.ok().entity(new String(result, StandardCharsets.UTF_8)).build();
    }

    @PUT
    @Path("/{id}")
    @Consumes("application/json")
    @Produces("application/json")
    @APIResponses(value = {
        @APIResponse(responseCode = "204", description = "Asset updated"),
        @APIResponse(responseCode = "400", description = "Error reading asset", content = @Content(mediaType = "application/json")),    
        @APIResponse(responseCode = "404", description = "Asset not found", content = @Content(mediaType = "application/json")) }) 
    @Operation(summary = "Update asset on the blockchain", description = "Updates an asset on the blockchain.")
    @Tag(name = "Assets")
    public Response updateAsset(@PathParam("id") String id, Asset asset) {
        Gateway gateway = BlockchainClient.getInstance();

        // Obtain a smart contract deployed on the network.
        Network network = gateway.getNetwork(ConnectionConfiguration.getChannel());
        Contract contract = network.getContract(ConnectionConfiguration.getContract());

        // Submit transactions to modify state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction(ConnectionConfiguration.getPutMethod(), id, asset.getAssetValue());
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }

        return Response.noContent().build();
    }

    @DELETE
    @Path("/{id}")
    @Produces("application/json")
    @APIResponses(value = {
        @APIResponse(responseCode = "204", description = "Asset Deleted"),
        @APIResponse(responseCode = "400", description = "Error reading asset", content = @Content(mediaType = "application/json")),    
        @APIResponse(responseCode = "404", description = "Asset not found", content = @Content(mediaType = "application/json")) }) 
    @Operation(summary = "Deletes asset from the blockchain", description = "Deletes asset from the blockchain.")
    @Tag(name = "Assets")
    public Response deleteAsset(@PathParam("id") String id) {
        Gateway gateway = BlockchainClient.getInstance();

        // Obtain a smart contract deployed on the network.
        Network network = gateway.getNetwork(ConnectionConfiguration.getChannel());
        Contract contract = network.getContract(ConnectionConfiguration.getContract());

        // Submit transactions to delete state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction(ConnectionConfiguration.getDeleteMethod(), id);
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }

        return Response.noContent().build();
    }    

    @POST
    @Consumes("application/json")
    @Produces("application/json")
    @APIResponses(value = {
        @APIResponse(responseCode = "204", description = "Asset Created"),
        @APIResponse(responseCode = "400", description = "Error reading asset", content = @Content(mediaType = "application/json")),    
        @APIResponse(responseCode = "404", description = "Asset not found", content = @Content(mediaType = "application/json")) }) 
    @Operation(summary = "Create asset on the blockchain", description = "Create asset on the blockchain.")
    @Tag(name = "Assets")
    public Response createAsset(Asset asset) {
        Gateway gateway = BlockchainClient.getInstance();

        // Obtain a smart contract deployed on the network.
        Network network = gateway.getNetwork(ConnectionConfiguration.getChannel());
        Contract contract = network.getContract(ConnectionConfiguration.getContract());

        // Submit transactions to add state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction(ConnectionConfiguration.getPostMethod(), asset.getAssetName(), asset.getAssetValue());
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }

        return Response.noContent().build();
    }
  
}