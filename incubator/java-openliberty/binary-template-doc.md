# Java Open Liberty Binary War Template

## Assumptions: 

- A fully formed war application file with no source code available - intention is to migrate it as is
- A server.xml file snippet written to support the application. It should contain:
    - features
    - datasource definitions

## Process:
1. Create a new appsody project using the java-openliberty stack binary template:

    ```
    appsody init java-openliberty binary
    ```

2. Add the fully formed war file to a local file based repository - or ensure it is available in a locally connected repository (.m2)

    > - In order to add a war file to a local file based repository you may use the subdirectory in the project called `migrationassets`<br> 
    > Install the war file into the local file based repository `migrationassets` using the following mvn command:<br>
    

    ```
    mvn deploy:deploy-file 
        -Durl=file://<file system location of project>/<project directory>/migrationassets 
        -Dfile=<name of war file>.war 
        -DgroupId=<application group id> 
        -DartifactId=<application artifact id> 
        -Dpackaging=war 
        -Dversion=1.0
    ```
3. Add a dependency stanza for the war file into the project pom file dependency list.
4. Add any shared library or datasource resource adapter dependency stanzas required by the application to the dependency section of the project pom file.
    > Note: any shared library or resource adapter jar files can also be installed in the local file based repository `migrationassets` using the same mvn deploy:deploy-file command as detailed in the previous section.
5. Place a correctly formed server.xml snippet file in the project directory:
    ``` 
    <file system location of project>\<project directory>\src\main\liberty\config
    ```   
6. Run the appsody build command for this application project:
    ```
    appsody build
    ```

## Result:

A docker runnable container containing a liberty server with the application correctly deployed within it.



    