# Crossplane - AWS Tenant Module

This Crossplane Composite Resource Definition (XRD) allows you to manage AWS
tenant users with restricted access. Using this XRD, you can specify which AWS
regions and services a tenant can use, while preventing them from escalating
privileges or accessing sensitive services.

> \[!CAUTION]
> This XRD is a work in progress and is not yet ready for production use (not working).\
> It is currently staying here for reference purposes if, in the future, I decide to
> continue working on it.

## Usage

To use this XRD, you must have a Crossplane installation running with the
[AWS provider](https://marketplace.upbound.io/providers/upbound/provider-aws-iam/latest),
[Go templating function](https://marketplace.upbound.io/functions/crossplane-contrib/function-go-templating/latest) and
[Auto ready function](https://marketplace.upbound.io/functions/crossplane-contrib/function-auto-ready/latest)
installed and configured.

### Install the XRD

To install the XRD, run the following command:

```shell
# TODO: Replace with the URL of the XRD package
kubectl apply --kustomize .
```

### Create a Tenant (example)

To create an AWS tenant that can only use the `us-west-2` region and the `ec2`
service, create a YAML file with the following content:

```yaml
apiVersion: aws.chezmoi.sh/v1alpha1
kind: Tenant
metadata:
  name: my-tenant
spec:
  enabledServices:
    - ec2
  enabledRegions:
    - us-west-2
  names:
    full: MyTenant
    slug: mytenant
  providerConfigRef:
    name: my-aws-provider-config
  writeConnectionSecretToRef:
    name: my-tenant-connection
```

Then, apply the YAML file to your Crossplane installation:

```shell
kubectl apply -f my-tenant.yaml
```

When the tenant is created, Crossplane will populate the `my-tenant-connection`
secret inside the same namespace with the tenant's AWS access key and secret key.

## Schema

This XRD defines a custom AWS tenant resource (`XTenant` and `Tenant`) with the
following properties:

| Field                       | Description                                                                                | Required |
| --------------------------- | ------------------------------------------------------------------------------------------ | -------- |
| spec.name.full              | Full name of the tenant (alphanumeric, hyphens, underscores, and periods allowed).         | Yes      |
| spec.name.slug              | Short, URL-friendly tenant identifier (only alphanumeric characters allowed).              | Yes      |
| spec.enabledRegions         | AWS regions where the tenant can create resources. Defaults to eu-west-3 if not specified. | No       |
| spec.enabledServices        | AWS services the tenant can use. Must specify at least one service.                        | Yes      |
| spec.providerConfigRef.name | Reference to the AWS provider configuration. Defaults to default.                          | Yes      |

## License

This XRD is released under the Apache 2.0 license. For more information, see the
[LICENSE](../../../../../../../LICENSE) file.
