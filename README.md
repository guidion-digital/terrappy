# Do You Need Terrappy? (Rationale)

If you want to manage your infrastructure and application deployments all with the same tooling, but keep degrees of separation for security and logical areas of responsibility, this may be the pseudo-framework for you. It was inspired by the [serverless.tf](https://serverless.tf/) project, but aims to make things even easier with further abstractions.

## How is this Different to Serverless.tf

The Serverless.tf project provides building blocks for deploying applications in AWS which the developer can then put together to form an application stack, much in the same way that the [Serverless Framework](https://www.serverless.com/) does, but with Terraform. Terrappy takes that one step further and abstracts away the individual components by asking only "_What type of application would you like to deploy?_".

From there, it makes opinionated decisions on the components to use, and how to put them together.

## How Does it Work?

There are three types of Terraform module in Terrappy:

- Application: The highest level module, bringing together other modules to deploy an application
- Helper: What application modules consist of
- Infra: Applied in an "infrastructure" repo ahead of time, in order to create the resources necessary for an application module to function

The `infra` modules set up Terraform Cloud workspaces (or pseudo-TFC workspaces which actually use S3 and DynamoDB to mimic TFC workspace functionality). Infra level modules create resources that application modules do not have permissions to create, and pass down names and ARNs to them to pick up and use. This includes IAM roles for services (such as Lambdas) to use.

### Workspaces

The [infra-workspaces](https://github.com/GuidionOps/terraform-tfe-infra-workspaces/) module creates a workspace for each `var.applications{}` entry, with:

- An AWS user with a set of permissions to create resources based on the selected `var.applications{}.app_type` selected
- An IAM role named after each application in that map, to pass to that application's services (more on this below)
- TFC variables needed for the application modules to use
- All the configuration necessary for a (by default) API driven TFC workspace strategy

You'll notice that `var.applications{}.app_type` is not available for the pseudo-workspace created by the [infra-s3-workspaces](https://github.com/GuidionOps/terraform-aws-infra-s3-workspaces/) module. This is because that module does not create an IAM user (and therefore can not be responsible for it's permissions). It is presumed that that module will be used with a pre-existing IAM user.

The infra-s3-workspaces module was created to be used with "development" environments, whereas the infra-workspaces module was designed for "production" environments. There is nothing stopping you from using either for either though. Bear in mind however, that you will always need to supply your own IAM user for the S3 version.

### Permissions System

The way in which permissions are assigned to an application is flexible. In order to provide application permissions, you may:

- Provide a raw policy to `var.applications{}.application_policy`. This will be added to the default role created for the application, and available by default to a variable created called `var.role_arn`
- Provide _predefined_ policies in `var.applications{}.application_policy_arns`
- Create roles with the required policies attached, and pass their names down via environment variables to the application that is to run in the workspace

In all cases the `var.applications{}.application_role_arn_names` list must contain roles that the services will assume, and the service type must be in the `var.applications{}.service_types` list. Only these roles (and those services) will be allowed to be allowed to be passed by the workspace user to the service. This isn't a concern when only using `var.applications{}.application_policy`, since the role that ends up in is automatically added to the list.

## Application Modules

There are currently three application types supported:

- [CDN](https://github.com/GuidionOps/terraform-aws-app-cdn-cf-s3): Deploys Cloudfront backed by S3. Handles domains, certificates, artifact updates. Corresponds to the `app_type` "cdn"
- [Container](https://github.com/GuidionOps/terraform-aws-app-container): Manages the deployment of AWS ECS containers. Corresponds to the `app_type` "container"
- [API Lambda](https://github.com/GuidionOps/terraform-aws-app-api-lambda): Deploys API Gateways backed by Lambdas. Handles domains, certificates, firewall, CloudWatch events (schedule, and patter), SQS, DynamoDB, with more supporting services coming as the need arises. Corresponds to the `app_type` "api"
