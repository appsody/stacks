package application.controller;

import java.util.concurrent.TimeoutException;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.ContractException;

import application.exceptions.AssetException;
import application.exceptions.AssetNotFoundException;
import application.model.MyAsset;

/*
In the controller package, create a class MyAssetController (remove FabricController, since it is not feasible to create a generic controller that introspects the Contract and understands what to do with it).
MyAssetController has four method - one per API resource (GET, PUT, POST, and DELETE).
All methods take the Contract and the model MyAsset object.
Each method will call the appropriate transaction on the Contract, and use the model Object to populate the parms.
*/

public class MyAssetController {

    public byte[] getMyAsset(Contract contract, String assetId) throws AssetException, AssetNotFoundException {
        byte[] results = null;
        try {
            results = contract.submitTransaction("readMyAsset", assetId);
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }
        return results;
    }

    public void createMyAsset(Contract contract, MyAsset asset) throws AssetException, AssetNotFoundException {
        // Submit transactions to add state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction("createMyAsset", asset.getMyAssetId(), asset.getValue());
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }
    }

    public void updateMyAsset(Contract contract, MyAsset asset) throws AssetException, AssetNotFoundException {
        // Submit transactions to modify state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction("updateMyAsset", asset.getMyAssetId(), asset.getValue());
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }
    }

    public void deleteMyAsset(Contract contract, String assetId) throws AssetException, AssetNotFoundException {
        // Submit transactions to delete state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction("deleteMyAsset", assetId);
        } catch (ContractException e1) {
            throw new AssetNotFoundException("Asset not found on the ledger");
        } catch (TimeoutException e1) {
            throw new AssetException("Trasaction timeout");
        } catch (InterruptedException e1) {
            throw new AssetException("Trasaction error");
        }
    }

}