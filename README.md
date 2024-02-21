N.B. Terrappy consists of many interdependent modules, and Guidion is still in the process of open sourcing them. This notice will be removed once the minimum dependency requirements are met, until then the ones that _are_ already available will not be of much use by themselves.

---

# Do You Need Terrappy? (Rationale)

If you want to manage your infrastructure and application deployments all with the same tooling, but keep degrees of separation for security and logical areas of responsibility, this may be the pseudo-framework for you. It was inspired by the [serverless.tf](https://serverless.tf/) project, but aims to make things even easier with further abstractions.

## How is this Different to Serverless.tf

The Serverless.tf project provides building blocks for deploying applications in AWS which the developer can then put together to form an application stack, much in the same way that the [Serverless Framework](https://www.serverless.com/) does, but with Terraform. Terrappy takes that one step further and abstracts away the individual components by asking only "_What type of application would you like to deploy?_".

From there, it makes opinionated decisions on the components to use, and how to put them together.

# How Does it Work?

There are three types of Terraform module in Terrappy:

- Application: The highest level module, bringing together other modules to deploy an application
- Helper: What application modules consist of
- Infra: Applied in an "infrastructure" repo ahead of time, in order to create the resources necessary for an application module to function

The `infra` modules set up Terraform Cloud workspaces (or pseudo-TFC workspaces which actually use S3 and DynamoDB to mimic TFC workspace functionality). Infra level modules create resources that application modules do not have permissions to create, and pass down names and ARNs to them to pick up and use. This includes IAM roles for services (such as Lambdas) to use.

## Workspaces

The [infra-workspaces](https://github.com/GuidionOps/terraform-tfe-infra-workspaces/) module creates a workspace for each `var.applications{}` entry. Utilising the [Permissions](./permissions.md) system, IAM roles and policies are created which give each workspace only the permissions it needs in order to deploy it's application. See the [Workspaces section in the Permissions](./permissions.md#workspaces) page for details on how this works.

## Application Permission System

The workspaces dish out permissions to the resources they create (e.g. Lambdas). The way in which permissions are assigned is flexible. See [Permissions](./permissions.md#applications) for how this works.

## Application Modules

Finally, we have the application modules which are the ultimate point for all the resources created by the modules above. There are currently three application types supported:

- [CDN](https://github.com/GuidionOps/terraform-aws-app-cdn-cf-s3): Deploys Cloudfront backed by S3. Handles domains, certificates, artifact updates. Corresponds to the `app_type` "cdn"
- [Container](https://github.com/GuidionOps/terraform-aws-app-container): Manages the deployment of AWS ECS containers. Corresponds to the `app_type` "container"
- [API Lambda](https://github.com/GuidionOps/terraform-aws-app-api-lambda): Deploys API Gateways backed by Lambdas. Handles domains, certificates, firewall, CloudWatch events (schedule, and pattern), SQS, DynamoDB, with more supporting services coming as the need arises. Corresponds to the `app_type` "api"

---

# Utilities

[TFCD](https://github.com/GuidionOps/terraform-cloud-deployer) is a CLI utility designed to provide low-level commands to TFC. It was used in the first iteration of Terrappy, before migrating to `terraform` commands, but is still used by the Terrappy Github workflow (see below) for it's `cancel` command.

The [Terrappy Github workflow](https://github.com/guidion-digital/terrappy/blob/beta/.github/workflows/tfc-deploy.yaml) exists as a convenience for integrating into your own workflows. You can use it like this:

```yaml
jobs:
  ...

  deploy_prod:
    permissions:
      issues: write
      contents: read
      pull-requests: write
    uses: guidion-digital/terrappy/.github/workflows/tfc-deploy.yaml@beta0.0.7
    with:
      organization: guidion
      workspace: FILL ME IN
      approvers: FILL ME IN
      source_dir: FILL ME IN
    secrets:
      tfc_api_token: ${{ secrets.TFC_API_TOKEN_PROD }}

  ...
```

Currently it will display a Terraform plan that needs to be approved (via an automatically created Github issue) on the `master` branch. This however, is not final and may change.
