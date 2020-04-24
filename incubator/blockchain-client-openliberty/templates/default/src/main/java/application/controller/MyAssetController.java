package application.controller;

import java.nio.charset.StandardCharsets;
import java.util.concurrent.TimeoutException;
import java.util.logging.Logger;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.ContractException;

import application.exceptions.AssetException;
import application.exceptions.AssetNotFoundException;
import application.model.MyAsset;

public class MyAssetController {

    private static final Logger LOGGER = Logger.getLogger(MyAssetController.class.getName());

    public byte[] getMyAsset(Contract contract, String assetId) throws AssetException, AssetNotFoundException {
        LOGGER.info("AssetId = " + assetId);
        byte[] results = null;
        try {
            results = contract.submitTransaction("readMyAsset", assetId);
        } catch (ContractException e) {
            LOGGER.severe("Contract Exception submitting transaction." + e.toString());
            throw new AssetNotFoundException("Asset not found on the ledger.", e);
        } catch (TimeoutException e) {
            LOGGER.severe("TimeoutException submitting transaction." + e.toString());
            throw new AssetException("Trasaction timeout.", e);
        } catch (InterruptedException e) {
            LOGGER.severe("Interrupted Exception submitting transaction." + e.toString());
            throw new AssetException("Trasaction error.", e);
        }
        LOGGER.info("Results = " + new String(results, StandardCharsets.UTF_8) );
        return results;
    }

    public void createMyAsset(Contract contract, MyAsset asset) throws AssetException, AssetNotFoundException {
        LOGGER.info(asset.toString());
        // Submit transactions to add state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction("createMyAsset", asset.getMyAssetId(), asset.getValue());
        } catch (ContractException e) {
            LOGGER.severe("Contract Exception submitting transaction." + e.toString());
            throw new AssetNotFoundException("Asset not found on the ledger.", e);
        } catch (TimeoutException e) {
            LOGGER.severe("TimeoutException submitting transaction." + e.toString());
            throw new AssetException("Trasaction timeout.", e);
        } catch (InterruptedException e) {
            LOGGER.severe("Interrupted Exception submitting transaction." + e.toString());
            throw new AssetException("Trasaction error.", e);
        }
    }

    public void updateMyAsset(Contract contract, MyAsset asset) throws AssetException, AssetNotFoundException {
        LOGGER.info(asset.toString());
        // Submit transactions to modify state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction("updateMyAsset", asset.getMyAssetId(), asset.getValue());
        } catch (ContractException e) {
            LOGGER.severe("Contract Exception submitting transaction." + e.toString());
            throw new AssetNotFoundException("Asset not found on the ledger.", e);
        } catch (TimeoutException e) {
            LOGGER.severe("TimeoutException submitting transaction." + e.toString());
            throw new AssetException("Trasaction timeout.", e);
        } catch (InterruptedException e) {
            LOGGER.severe("Interrupted Exception submitting transaction." + e.toString());
            throw new AssetException("Trasaction error.", e);
        }
    }

    public void deleteMyAsset(Contract contract, String assetId) throws AssetException, AssetNotFoundException {
        LOGGER.info("AssetId = " + assetId);
        // Submit transactions to delete state on the ledger
        try {
            // transaction has no return value
            contract.submitTransaction("deleteMyAsset", assetId);
        } catch (ContractException e) {
            LOGGER.severe("Contract Exception submitting transaction." + e.toString());
            throw new AssetNotFoundException("Asset not found on the ledger.", e);
        } catch (TimeoutException e) {
            LOGGER.severe("TimeoutException submitting transaction." + e.toString());
            throw new AssetException("Trasaction timeout.", e);
        } catch (InterruptedException e) {
            LOGGER.severe("Interrupted Exception submitting transaction." + e.toString());
            throw new AssetException("Trasaction error.", e);
        }
    }
}