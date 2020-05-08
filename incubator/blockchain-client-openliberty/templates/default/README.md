# Default template for Blockchain with Open Liberty

## Introduction

The intent of the default template in the Blockchain Open Liberty stack is to provide a working example that easily integrates with the default Smart Contract provided by The IBM® Blockchain Platform Visual Studio (VS) Code extension.(<https://cloud.ibm.com/docs/services/blockchain/howto?topic=blockchain-develop-vscode)>

That default Smart Contract is called MyAsset and following a minimal set of instructions detailed in the link above you can have a Fabric Network running the MyAsset Smart Contract.  This template provides an means to easily bind a Java Openlibery Service to the MyAsset Smart Contract. For learning purposes your new project is able to run, connect and execute transactions without any code changes. Not only can you bind to a Local Fabric Instance created by VSCode, you can in fact interact with any Blockchain Fabric Network instance.(<https://www.ibm.com/blockchain/platform)>

The template provides a well structured web application with common componently to get you starting with all things common to transacting on a fabric network.  This starting point is for you to refactor, extend and customize to meet your own project requirements. There are a few component layers that you will want to refactor for your projects needs and a few to only configure. The API Layer, Identity Mapping Layer and finally the Transaction Management Layer. In the following sections we will define layer.

## Required Envirnment Variables

Here is a complete list of the supported environment variables as well as an example configuration.

***FABRIC_CONNECTION_PROFILE*** : Blockchain standard document that determines how a gateway connects to a fabric network.  <https://hyperledger-fabric.readthedocs.io/en/release-2.0/developapps/connectionprofile.html> This document should be "compressed/minified" so that there are no spaces or line breaks.

***FABRIC_WALLET_PROFILE*** : Setting to specify how the service finds and loads the identies. There are two supported types out of the box. In memory or filesystem. This document should be "compressed/minified" so that there are no spaces or line breaks.

`{"type":"IN_MEMORY"}`

`{"type":"FILE_SYSTEM","options":{"path":"/project/user-app/src/main/java/application/Org1"}}`

option.path : is that path to the file system wallet structure in compliance with the SDK wallet structure. This file MUST be included in the project and is for ***DEVELOPMENT PURPOSES ONLY***.

***FABRIC_WALLET_CREDENTIALS*** : A JSON array of fabric identies used when using IN_MEMORY wallet type. (See sample below). This document should be "compressed/minified" so that there are no spaces or line breaks. Additionally, the cert and private_key attribute values ***MUST be base64 encoded.***

***FABRIC_CHANNEL*** : Fabric network channel
***FABRIC_CONTRACT*** : Installed and Instantiated Smart Contract on the FABRIC_CHANNEL
***FABRIC_DEFAULT_IDENTITY*** : The default identity to use when transacting with the fabric network.

### EXAMPLE ENVIRONMENT FILE

    FABRIC_CONNECTION_PROFILE={"certificateAuthorities":{"Org1CA":{"caName":"ca","url":"http://localhost:17050"}},"client":{"connection":{"timeout":{"orderer":"300","peer":{"endorser":"300"}}},"organization":"Org1MSP"},"name":"Org1","organizations":{"Org1MSP":{"certificateAuthorities":["Org1CA"],"mspid":"Org1MSP","peers":["Org1Peer1"]}},"peers":{"Org1Peer1":{"url":"grpc://localhost:17051"}},"version":"1.0.0"}
    FABRIC_WALLET_PROFILE={"type":"IN_MEMORY"}
    FABRIC_WALLET_CREDENTIALS=[{"cert":"LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNXVENDQWYrZ0F3SUJBZ0lVTVQwa2JuZlRnaFR1S1MvS2RySkI5YjU2ZlZFd0NnWUlLb1pJemowRUF3SXcKZnpFTE1Ba0dBMVVFQmhNQ1ZWTXhFekFSQmdOVkJBZ1RDa05oYkdsbWIzSnVhV0V4RmpBVUJnTlZCQWNURFZOaApiaUJHY21GdVkybHpZMjh4SHpBZEJnTlZCQW9URmtsdWRHVnlibVYwSUZkcFpHZGxkSE1zSUVsdVl5NHhEREFLCkJnTlZCQXNUQTFkWFZ6RVVNQklHQTFVRUF4TUxaWGhoYlhCc1pTNWpiMjB3SGhjTk1qQXdOREUxTVRjME9UQXcKV2hjTk1qRXdOREUxTVRjMU5EQXdXakJkTVFzd0NRWURWUVFHRXdKVlV6RVhNQlVHQTFVRUNCTU9UbTl5ZEdnZwpRMkZ5YjJ4cGJtRXhGREFTQmdOVkJBb1RDMGg1Y0dWeWJHVmtaMlZ5TVE4d0RRWURWUVFMRXdaamJHbGxiblF4CkRqQU1CZ05WQkFNVEJXRmtiV2x1TUZrd0V3WUhLb1pJemowQ0FRWUlLb1pJemowREFRY0RRZ0FFZEZ0ZEZTVk4KcXd3TGU1ajZRMVVqd056eXhGbXpuK3pTbzRGbEZFdVplR0FJZER0OGQwcENjLytxRFNCZlB4SVREeEpONWt5ZAo2bHdhTmoxYnFObHhDYU43TUhrd0RnWURWUjBQQVFIL0JBUURBZ2VBTUF3R0ExVWRFd0VCL3dRQ01BQXdIUVlEClZSME9CQllFRkdGTEZPWUJJdWNBRGFTRHk3emdadm5IZWJKak1COEdBMVVkSXdRWU1CYUFGQmRuUWoycW5vSS8KeE1VZG4xdkRtZEcxbkVnUU1Ca0dBMVVkRVFRU01CQ0NEbVJ2WTJ0bGNpMWtaWE5yZEc5d01Bb0dDQ3FHU000OQpCQU1DQTBnQU1FVUNJUURkUFpsajJ3KzBZdXArV1JxSEtNaWI4QmdJdHg5VTBLVk9rUGlveHVtSnhnSWdmQi9iCnVpbFl4d3RXMUN0bENLYXY1Z29pWnRhbHEzbi9hbHpVbVpSMjRqTT0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQ==","msp_id":"Org1MSP","name":"admin","private_key":"LS0tLS1CRUdJTiBQUklWQVRFIEtFWS0tLS0tCk1JR0hBZ0VBTUJNR0J5cUdTTTQ5QWdFR0NDcUdTTTQ5QXdFSEJHMHdhd0lCQVFRZ3FCNHBRNE5PRFZzT2RMR2MKYWxSM3NCcm9WM095aSs2MGpDdVpZK001blF1aFJBTkNBQVIwVzEwVkpVMnJEQXQ3bVBwRFZTUEEzUExFV2JPZgo3TktqZ1dVVVM1bDRZQWgwTzN4M1NrSnovNm9OSUY4L0VoTVBFazNtVEozcVhCbzJQVnVvMlhFSgotLS0tLUVORCBQUklWQVRFIEtFWS0tLS0t"}]
    FABRIC_CHANNEL=mychannel
    FABRIC_CONTRACT=myasset
    FABRIC_DEFAULT_IDENTITY=admin

## WalletManagement

Wallet(s) are a concept in the fabric SDK that contain identities for transacting on your fabric network. To remain consistent with the terminology we have created the a WalletManager class that contains code for easily onboarding fabric identities into the service.  The WalletManager is intensionally extendable so other wallet implementations can easily be made use of. The purpose of this component is house all the fabric identifies your service will want to transact with. The approach is entirely configuration driven, there are 2 modes of operation out of the box.

`FABRIC_WALLET_PROFILE={"type":"IN_MEMORY"}`

`FABRIC_WALLET_PROFILE={"type":"FILE_SYSTEM","options":{"path":"/project/user-app/src/main/java/application/Org1"}}`

Creating your own Wallet backend is as simple as creating Wallet Implementation, adding configuration and adding a configuration type so the wallet manager can load the new implementation when configured.

## API and Data Model

The API Layer is the REST API definition layer for the micro service. This layer defines the set of input and output for each REST API endpoints the service exposes. In the template this component is simply AssetService.java. Looking at the class you will notice a set of open api annotations for each function. It is a best practice to use the Open API specification to document each endpoint, this enables an easy way for developers to test and also provides self service documentation to client consumers of the service.

The Data Model layer are the Java Object that represent the set of inputs and output you wish to model. In the sample this component is simply Asset.java.

## Identity Mapping

Every service should be secure and provide a mechanism for authentication. The strategies you choose are beyond the scope of what the application template can provide, however we thought it important there be a minimal set of components that address the issue of mapping a service user to a user of an organization of a fabric network that the service user is acting on behalf. Here is the explanation of how the provider identity parts are meant to be use …

### Identity Request Flow

1. IdentityMapperFilter intercepts the request ahead of being routed to the API resource.  (Pre request filter)
1. Invokes extractPrincipal(ContainerRequestContext) to get the request identity.
1. By default the filter method then returns the default identity, based on the FABRIC_DEFAULT_IDENTITY environment variable.
In a more sophisticated implementation, the mapper would call out to a rule engine, or to a database to perform the mapping.
1. The identity is then set in an HTTP Header named X-FABRIC-IDENTITY.
1. The request now gets routed to the API resource.
1. The resource logic extracts the identity from the X-FABRIC-IDENTITY header and uses it to call getContract(identity) on the ConnectionManager.

## Enabling Logging

The following set of properties control the behavior from an env file and are common to websphere. 
Add the following settings to the environment file that is needed by the template.

WLP_LOGGING_CONSOLE_FORMAT=basic
WLP_LOGGING_CONSOLE_LOGLEVEL=info
WLP_LOGGING_CONSOLE_SOURCE=message,trace,accessLog,ffdc,audit

WLP_LOGGING_MESSAGE_SOURCE=message
WLP_LOGGING_MESSAGE_FORMAT=json

<https://www.ibm.com/support/knowledgecenter/SSEQTP_liberty/com.ibm.websphere.wlp.doc/ae/rwlp_logging.html>

Its worth noting, the stack does not tolerate changes message.log setting to JSON as the stack expects a specific message for the liberty dev plugin.

```bash
[Container] [INFO] ------------------------------------------------------------------------
[Container] [INFO] BUILD FAILURE
[Container] [INFO] ------------------------------------------------------------------------
[Container] [INFO] Total time: 59.154 s
[Container] [INFO] Finished at: 2020-04-22T20:28:52Z 
[Container] [INFO] ------------------------------------------------------------------------
[Container] [ERROR] Failed to execute goal io.openliberty.tools:liberty-maven-plugin:3.2:dev (default-cli) on project starter-app: Could not parse the host name from the log message: {"type":"liberty_message","host":"b10c3a9ac6d0","ibm_userDir":"/opt/ol/wlp/usr/","ibm_serverName":"defaultServer","message":"CWWKT0016I: Web application available (default_host): http://b10c3a9ac6d0:9080/metrics/","ibm_threadId":"00000034","ibm_datetime":"2020-04-22T20:28:22.369+0000","ibm_messageId":"CWWKT0016I","module":"com.ibm.ws.http.internal.VirtualHostImpl","loglevel":"AUDIT","ibm_sequence":"1587587302369_000000000001F"} -> [Help 1]
```

## Deploy
