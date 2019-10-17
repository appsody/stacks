
1. Deploy pipeline
    ```
    oc apply -f tekton/collections-build-task.yaml -n kabanero
    ```

1. Configure security constraints for service account
    ```
    oc adm policy add-scc-to-user privileged -z kabanero-index -n kabanero
    ```

1. Create `tekton/collections-build-task-run.yaml` pipeline run file with the following contents. Fill in the `revision`, `url`, and `clusterSubdomain` properties:
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

1. If you are using GitHub Enterprise, create a secret following https://github.com/tektoncd/pipeline/blob/master/docs/auth.md#basic-authentication-git instructions and associate it with the `kabanero-index` service account. For example:
    ```
    oc secrets link kabanero-index basic-user-pass
    ```

1. Trigger build
    ```
    oc delete -n kabanero --ignore-not-found -f tekton/collections-build-task-run.yaml; sleep 5; oc apply -n kabanero -f tekton/collections-build-task-run.yaml
    ```
