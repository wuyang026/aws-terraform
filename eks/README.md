# AWS EKS **Auto Mode** Terraform 
eks cluster auto mode with customized  node class and node pools with amd64 and arm64

This repo provides the Terraform configuration to deploy a demo app running on an AWS EKS Cluster with Auto Mode enabled, using best practices.

### Provisioning EKS Cluster
- Clone the repo 
```cython
  git clone https://github.com/xxxx
```
- Go to `eks` directory and initialize terraform
```cython
  terraform init -upgrade
```

### Make sure:

- Provide Existing vpc id 

- Private Subnet has the following tags
  ```cython
   key = value
  ```
- Now deploy infra
```cython
  terraform plan
```
```cython
  terraform apply
```
**Following resources will be created once you apply terraform**

## Deleting the cluster
Then delete the EKS related resources:

```
terraform destroy
```

