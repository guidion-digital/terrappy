# Developer Terraform Preparation Script

[Terraform is run on the local developer machines for Development stages](https://guidiondev.atlassian.net/wiki/spaces/DIG/pages/4002414604/Development+Stage+Deploys).

To configure the backend correctly, a helper script is provided. The script takes two required arguments; the project and application names, and a [third optional argument which enables sub-namespacing](#Sub-namespacing). For example, when configuring the development backend for the 'circleci' application in the 'web' project, run:

```sh
curl -s https://raw.githubusercontent.com/guidion-digital/terrappy/master/prepare_terraform_backend.sh | bash -s -- web circleci
```

It will try and be helpful if arguments are not supplied:

```sh
# Without providing project name
#
curl -s https://raw.githubusercontent.com/guidion-digital/terrappy/master/prepare_terraform_backend.sh | bash -s

Please provde the project name as the first argument (e.g. 'web'
Hint:
2023-03-21 13:15:37 aws-cloudtrail-logs-web-dev-events-test
2023-05-08 15:58:42 nuna-dev-afsprk-nl-origin
2023-05-17 10:37:55 web-dev-terraform-backends
```

```sh
# Without providing application name
#
curl -s https://raw.githubusercontent.com/guidion-digital/terrappy/master/prepare_terraform_backend.sh | bash -s -- web

Please provde one of these for the 'workspace' name as the second argument:
                           PRE afsprk_nl/
                           PRE circleci/
```

## Sub-namespacing

If `namespaced` is given as a value, the user's username will be used as a suffix for:

- The `name_suffix` variable (it will be inserted into `terraform.tfvars`)
- The Terraform workspace (non-TFC) will be switched to this namespace (created if non-existent)

This is useful where you wish to deploy the same application in the same AWS account, e.g. for development teams working on the same application at the same time.

You must ensure that the IAM policies for the application still work for the namespaced resources. For example, if you had policies allowing operations on `arn:aws:ssm:eu-central-1:012345678901:parameter/applications/foobar`, (where "foobar" was your application name) it will now have to be `arn:aws:ssm:eu-central-1:012345678901:parameter/applications/foobar-*`.
