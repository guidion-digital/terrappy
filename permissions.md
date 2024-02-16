# Workspaces

Each application workspace created by the [workspace module](https://github.com/GuidionOps/terraform-tfe-infra-workspaces/) gets:

- An AWS user with a set of permissions to create resources based on the selected `var.applications{}.app_type` selected — and only those permissions
- An IAM role named after each application in that map, to pass to that application's services. Only this role and others explicitly given are allowed to be passed via `iam:PassRole` (more on this in the "Applications" section below)
- TFC variables needed for the application modules to use
- All the configuration necessary for a (by default) API driven TFC workspace strategy

You'll notice that `var.applications{}.app_type` is not available for the pseudo-workspace created by the [infra-s3-workspaces](https://github.com/guidion-digital/terraform-aws-infra-s3-workspaces) module. This is because that module does not create an IAM user (and therefore can not be responsible for it's permissions). It is presumed that that module will be used with a pre-existing IAM user by developers directly on their machines.

The infra-s3-workspaces module was created to be used with "development" environments, whereas the infra-workspaces module was designed for "production" environments, and CI/CD. There is nothing stopping you from using either for either though. Bear in mind however, that you will always need to supply your own IAM user for the S3 version.

# Applications

## The Default Application Role

Whilst you can provide roles for your services to use (see below), a default role is always created and available for use too. By default, it provides only permission to create CloudWatch log groups within the `var.application_name` namespace, and the ability to write logs to them.

In order to add more permissions to the default role, you may:

- Provide a raw policy to `var.applications{}.application_policy`. This will be added to the default role created for the application, and available by default to a variable created called `var.role_arn`
- Provide _predefined_ policies in `var.applications{}.application_policy_arns`

The ARN of the default role is provided in a variable called `var.role_arn`, available in both the [S3 version of the workspace module](https://github.com/guidion-digital/terraform-aws-infra-s3-workspaces), and the [TFC version](https://github.com/guidion-digital/terraform-tfe-infra-workspaces).

## Using Roles Other than the Default Role

You may wish to create and assignd roles other than the default role to your services. This is useful for example when you wish to give different Lambdas within your stack different permissions. In this case, you would create these roles a layer above (before calling) the [workspace module](https://github.com/guidion-digital/terraform-tfe-infra-workspaces), and pass them to `var.applications{}.application_role_arn_names`. Not telling `application_role_arn_names` about your roles will result in an IAM pass role denied error, since only roles given to this variable will be allowed to be passed by your workspace user.

You must then communicate which role is to be used for which service yourself. One way of doing this is with evironment variables. This isn't a concern when only using `var.applications{}.application_policy`, since the role that ends up in is automatically added to the allowed list.

## Supporting Services

When you provide values to `service_types` and `supporting_services` in `var.applications{}`, permissions are created for those "service_types" to access those "supporting_services".

For example:

```hcl
...

  service_types       = "lambda",
  supporting_services = "dynamodb"

...
```

will grant Lambdas in the `var.application_name` namespace read/write access to DynamoDB tables in that same namespace.
