package application.api;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.fail;
import static org.mockito.Mockito.mock;
import static org.mockito.Mockito.when;

import java.util.concurrent.TimeoutException;

import org.hyperledger.fabric.gateway.Contract;
import org.hyperledger.fabric.gateway.ContractException;
import org.junit.Test;

import application.api.exceptions.AssetException;
import application.api.exceptions.AssetNotFoundException;
import application.api.MyAsset;

/**
 * MyAssetControllerTest
 */
public class MyAssetControllerTest {

    // Test Get Asset
    @Test
    public void testGetMyAsset() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        String assetId = "fakeAsset";
        byte[] expectedValue = "testValue".getBytes();

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.evaluateTransaction("readMyAsset", assetId)).thenReturn(expectedValue);

        MyAssetController controller = new MyAssetController();
        byte[] results = controller.getMyAsset(mock, assetId);

        assertEquals(expectedValue, results);
    }

    @Test(expected = AssetNotFoundException.class)
    public void testGetMyAssetContactException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        String assetId = "fakeAsset";

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.evaluateTransaction("readMyAsset", assetId))
                .thenThrow(new ContractException("Test Contract Exception"));

        MyAssetController controller = new MyAssetController();
        controller.getMyAsset(mock, assetId);

        fail("Expected Asset Exception");
    }

    // Test Create Asset
    @Test
    public void testCreatetMyAsset() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");
        byte[] expectedValue = "testValue".getBytes();

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("createMyAsset", asset.getMyAssetId(), asset.getValue())).thenReturn(expectedValue);

        MyAssetController controller = new MyAssetController();
        controller.createMyAsset(mock, asset);

        // This transaction does not have a return value.
    }

    @Test(expected = AssetNotFoundException.class)
    public void testCreateMyAssetContactException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("createMyAsset", asset.getMyAssetId(), asset.getValue()))
                .thenThrow(new ContractException("Test Contract Exception"));

        MyAssetController controller = new MyAssetController();
        controller.createMyAsset(mock, asset);

        fail("Expected Asset Exception");
    }

    @Test(expected = AssetException.class)
    public void testCreateMyAssetTimeoutException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("createMyAsset", asset.getMyAssetId(), asset.getValue()))
                .thenThrow(new TimeoutException());

        MyAssetController controller = new MyAssetController();
        controller.createMyAsset(mock, asset);

        fail("Expected Asset Exception");
    }

    @Test(expected = AssetException.class)
    public void testCreateMyAssetInterruptedException()
            throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("createMyAsset", asset.getMyAssetId(), asset.getValue()))
                .thenThrow(new InterruptedException());

        MyAssetController controller = new MyAssetController();
        controller.createMyAsset(mock, asset);

        fail("Expected Asset Exception");
    }

    // Test Update Asset
    @Test
    public void testUpdateMyAsset() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");
        byte[] expectedValue = "testValue".getBytes();

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("updateMyAsset", asset.getMyAssetId(), asset.getValue())).thenReturn(expectedValue);

        MyAssetController controller = new MyAssetController();
        controller.updateMyAsset(mock, asset);

        // This transaction does not have a return value.
    }

    @Test(expected = AssetNotFoundException.class)
    public void testUpdateMyAssetContactException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("updateMyAsset", asset.getMyAssetId(), asset.getValue()))
                .thenThrow(new ContractException("Test Contract Exception"));

        MyAssetController controller = new MyAssetController();
        controller.updateMyAsset(mock, asset);

        fail("Expected Asset Exception");
    }

    @Test(expected = AssetException.class)
    public void testUpdateMyAssetTimeoutException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("updateMyAsset", asset.getMyAssetId(), asset.getValue())).thenThrow(new TimeoutException());

        MyAssetController controller = new MyAssetController();
        controller.updateMyAsset(mock, asset);

        fail("Expected Asset Exception");
    }

    @Test(expected = AssetException.class)
    public void testUpdateMyAssetInterruptedException()
            throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        MyAsset asset = new MyAsset("testId", "testValue");

        // Mock the fabric call
        Contract mock = mock(Contract.class);
        when(mock.submitTransaction("updateMyAsset", asset.getMyAssetId(), asset.getValue())).thenThrow(new InterruptedException());

        MyAssetController controller = new MyAssetController();
        controller.updateMyAsset(mock, asset);

        fail("Expected Asset Exception");
    }

     // Test Delete Asset
     @Test
     public void testDeleteMyAsset() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        String assetId = "fakeAsset";
        byte[] expectedValue = "testValue".getBytes();
 
         // Mock the fabric call
         Contract mock = mock(Contract.class);
         when(mock.submitTransaction("deleteMyAsset", assetId)).thenReturn(expectedValue);
 
         MyAssetController controller = new MyAssetController();
         controller.deleteMyAsset(mock, assetId);
 
         // This transaction does not have a return value.
     }
 
     @Test(expected = AssetNotFoundException.class)
     public void testDeleteMyAssetContactException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        String assetId = "fakeAsset";
 
         // Mock the fabric call
         Contract mock = mock(Contract.class);
         when(mock.submitTransaction("deleteMyAsset", assetId))
                 .thenThrow(new ContractException("Test Contract Exception"));
 
         MyAssetController controller = new MyAssetController();
         controller.deleteMyAsset(mock, assetId);
 
         fail("Expected Asset Exception");
     }
 
     @Test(expected = AssetException.class)
     public void testDeleteMyAssetTimeoutException() throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        String assetId = "fakeAsset";
 
         // Mock the fabric call
         Contract mock = mock(Contract.class);
         when(mock.submitTransaction("deleteMyAsset", assetId)).thenThrow(new TimeoutException());
 
         MyAssetController controller = new MyAssetController();
         controller.deleteMyAsset(mock, assetId);
 
         fail("Expected Asset Exception");
     }
 
     @Test(expected = AssetException.class)
     public void testDeleteMyAssetInterruptedException()
             throws ContractException, TimeoutException, InterruptedException {
        // Value Setup
        String assetId = "fakeAsset";
 
         // Mock the fabric call
         Contract mock = mock(Contract.class);
         when(mock.submitTransaction("deleteMyAsset", assetId)).thenThrow(new InterruptedException());
 
         MyAssetController controller = new MyAssetController();
         controller.deleteMyAsset(mock, assetId);
 
         fail("Expected Asset Exception");
     }   
}