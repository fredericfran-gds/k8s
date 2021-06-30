# K8s Secrets Manager

## Build & deploy image

1. docker build and  tag docker image with repository & version

   ```sh
   docker build -t <docker_image_id> <repository>:<tagname> .
   ```

   where:  
   i. `<docker_image_id>` is the ID of the Docker image as obtained from `docker images` cmd  
   ii. `<repository>` is the docker repository e.g. `fredericfran/k8s_ruby_secrets_manager`  
   iii. `<tagname>` is the tag of the image e.g. `0.0.2`

1. push the docker image to the the repository

   ```sh
   docker push <repository>:<tagname>
   ```

1. run a one-off container of the docker image in k8s cluster

   ```sh
   gds aws govuk-test-admin -- kubectl run -i --tty secretsmanager --image=<repository>/<tagname> --restart=Never --overrides='{ "apiVersion": "v1", "spec": {"serviceAccountName": "signon-secrets-management" } }' -- /bin/bash  
   ```

   attach to the container:

   ```sh
   gds aws govuk-test-admin -- kubectl exec --stdin --tty secretsmanager -- /bin/bash
   ```

1. go to the bin folder and run any ruby script you want

   ```sh
   cd /src/bin & ruby <ruby_script_name>
   ```
