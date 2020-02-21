
Use these steps to trigger a Tekton pipeline build of your collections repository. The pipeline will build the stacks and deploy a `kabanero-index` container into your cluster. The `kabanero-index` container hosts the stacks index file and related assets.

1. Deploy build task and pipeline
    ```
    oc -n kabanero apply -f stacks-build-task.yaml -f stacks-build-pipeline.yaml
    ```

1. Configure security constraints for service account
    ```
    oc -n kabanero adm policy add-scc-to-user privileged -z kabanero-index
    ```

1. Create `stacks-build-git-resource.yaml` file with the following contents. Modify `revision` and `url` properties as needed. 
    ```
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineResource
    metadata:
      name: stacks-build-git-resource
    spec:
      params:
      - name: revision
        value: master
      - name: url
        value: https://github.com/kabanero-io/collections.git
      type: git
    ```

1. Deploy the `stacks-build-git-resource.yaml` file via `oc -n kabanero apply -f stacks-build-git-resource.yaml`

1. If you are using GitHub Enterprise, [create a secret](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-git) and associate it with the `kabanero-index` service account. For example:
    ```
    oc -n kabanero secrets link kabanero-index basic-user-pass
    ```

1. Create `stacks-build-pipeline-run.yaml` file with the following contents.

    ```
    apiVersion: tekton.dev/v1alpha1
    kind: PipelineRun
    metadata:
      name: stacks-build-pipeline-run
      namespace: kabanero
    spec:
      pipelineRef:
        name: stacks-build-pipeline
      resources:
      - name: git-source
        resourceRef:
          name: stacks-build-git-resource
      params:
        - name: stacks
          value: all
      serviceAccountName: kabanero-index
      timeout: 60m
    ```

1. If you are deploying the stack images into a private container registry, [create a Docker registry's secret](https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#kubernetess-docker-registrys-secret) and associate it with the `kabanero-index` service account.
    ```
    oc -n kabanero secrets link kabanero-index my-registry --for=pull,mount
    ```

1. Trigger build
    ```
    oc -n kabanero delete --ignore-not-found -f stacks-build-pipeline-run.yaml
    sleep 5
    oc -n kabanero apply -f stacks-build-pipeline-run.yaml
    ```

    You can track the pipeline execution in the Tekton dashboard or via CLI:
    ```
    oc -n kabanero logs $(oc -n kabanero get pod -o name -l tekton.dev/task=stacks-build-task) --all-containers -f 
    ```

   After the build completes successfully, a `kabanero-index` container is deployed into your cluster.

1. Get the route for the `kabanero-index` pod and use it to generate a stacks index URL:

    ```
    STACKS_INDEX_URL=$(oc -n kabanero get route kabanero-index --no-headers -o=jsonpath='http://{.status.ingress[0].host}/kabanero-index.yaml')
    echo $STACKS_INDEX_URL
    ```

1. Follow the [configuring a Kabanero CR instance](https://kabanero.io/docs/ref/general/configuration/kabanero-cr-config.html) documentation to configure or deploy a Kabanero instance with the `STACKS_URL` obtained in the previous step. 
