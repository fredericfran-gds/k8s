# AWS EKS

## Procedure

1. Create cluster

```sh
gds aws govuk-test-admin -- terraform init -backend-config test.backend
gds aws govuk-test-admin -- terraform apply
```

2. Update kubeconfig

```sh
gds aws govuk-test-admin -- aws eks --region eu-west-1 update-kubeconfig --name fred
```

test by:

```sh
gds aws govuk-test-admin -- kubectl get nodes
```

3. Add Content-store

```sh
gds aws govuk-test-admin -- kubectl apply -f apps/content-store/app.yml
```
