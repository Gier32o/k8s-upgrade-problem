# Problem

There are pods with ContainerCreating status after upgrading EKS cluster to 1.30 version when Security Groups for Pods feature is turned on

# Requirements

Needs already existing VPC and Subnets

## default.tfvars

Create file default.tfvars with missing variables from variables.tf file

# Installation

## Init

`terraform init`

## Install

`terraform apply -var-file=default.tfvars -var-file=vars/install.tfvars`

## Deploy 30 pods

`kubectl create deployment hello-node --replicas 30 --image=registry.k8s.io/e2e-test-images/agnhost:2.39 -- /agnhost netexec --http-port=8080`

5 Pods are in Pending status

## Upgrade

`terraform apply -var-file=default.tfvars -var-file=vars/upgrade.tfvars`

5 Pods are in Pending status, 9 Pods are in ContainerCreating status:

```shell
Warning  FailedCreatePodSandBox  19m                 kubelet            Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network for sandbox "cffd4f13c293011d5f6e967bd5859c234ab1f83731fbf1e40c46330e6276fdd7": plugin type="aws-cni" name="aws-cni" failed (add): add cmd: failed to assign an IP address to container
Warning  FailedCreatePodSandBox  66s (x85 over 19m)  kubelet            (combined from similar events): Failed to create pod sandbox: rpc error: code = Unknown desc = failed to setup network for sandbox "38c6783c31d39443b9b0fe4873868fdf972c92d499176b5b44c9df42b4461865": plugin type="aws-cni" name="aws-cni" failed (add): add cmd: failed to assign an IP address to container
```

# Destroy

`terraform destroy -var-file=default.tfvars -var-file=vars/upgrade.tfvars`