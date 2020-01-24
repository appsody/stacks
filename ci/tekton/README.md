
Use these steps to trigger a Tekton pipeline build of your collections repository. The pipeline will build the collections and deploy a `kabanero-index` container into your cluster. The `kabanero-index` container hosts the Kabanero collections index file and related assets.

1. Deploy pipeline
    ```
    oc -n kabanero apply -f tekton/collections-build-task.yaml 
    ```

1. Configure security constraints for service account
    ```
    oc -n kabanero adm policy add-scc-to-user privileged -z kabanero-index
    ```

1. Create `tekton/collections-build-task-run.yaml` file with the following contents. Modify the the `revision` and `url` parameters with your Kabanero collections repository information. Optionally, provide the `clusterSubdomain` parameter that specifies the subdomain for your cluster:
    ```
    apiVersion: tekton.dev/v1alpha1
    kind: TaskRun
    metadata:
      name: collections-build-task-run
    spec:
      serviceAccount: kabanero-index
      taskRef:
        name: collections-build-task
      inputs:
        resources:
          - name: git-source
            resourceSpec:
              type: git
              params:
                - name: revision
                  value: master
                - name: url
                  value: https://github.com/kabanero/collections.git
        params:
          - name: clusterSubdomain
            value: example.com
    ```

1. If you are using GitHub Enterprise, [create a secret](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-git) and associate it with the `kabanero-index` service account. For example:
    ```
    oc -n kabanero secrets link kabanero-index basic-user-pass
    ```

1. Trigger build
    ```
    oc -n kabanero delete --ignore-not-found -f tekton/collections-build-task-run.yaml
    sleep 5
    oc -n kabanero apply -f tekton/collections-build-task-run.yaml
    ```

    You can track the pipeline execution in the Tekton dashboard or via CLI:
    ```
    oc -n kabanero logs $(oc -n kabanero get pod -o name -l tekton.dev/task=collections-build-task) --all-containers -f 
    ```

   After the build completes successfully, a `kabanero-index` container is deployed into your cluster.

1. Get the route for the `kabanero-index` pod and use it to generate a collections URL:

    ```
    COLLECTIONS_URL=$(oc -n kabanero get route kabanero-index --no-headers -o=jsonpath='http://{.status.ingress[0].host}/kabanero-index.yaml')
    echo $COLLECTIONS_URL
    ```

1. Follow the [configuring a Kabanero CR instance](https://kabanero.io/docs/ref/general/configuration/kabanero-cr-config.html) documentation to configure or deploy a Kabanero instance with the `COLLECTIONS_URL` obtained in the previous step. 
