If you use Github Actions workflows, you can make use of the [Terrappy re-usable workflows](.github/workflows/). There are two flavours; one that you can use on any plan, and one that requires a Github Enterprise feature called "deployment approvals".

- Free plan workflow: `guidion-digital/terrappy/.github/workflows/tfc-deploy.yaml@CHECK_FOR_LATEST_TAG`
- Enterprise plan workflow: `guidion-digital/terrappy/.github/workflows/tfc-deploy-enterprise.yaml@CHECK_FOR_LATEST_TAG`

## Providing Inputs vs. Using Environments

Using the free plan version for an example, if you'd like to pass the required variables and secrets via inputs, you can do so like this:

```yaml
  deploy:
    needs: build_and_test
    permissions:
      issues: write
      contents: read
      pull-requests: write
    uses: guidion-digital/terrappy/.github/workflows/tfc-deploy.yaml@CHECK_FOR_LATEST_TAG
    with:
      organization: guidion
      workspace: ${{ vars.WORKSPACE }}
    secrets:
      tfc_api_token: ${{ secrets.TFC_API_TOKEN }}
```

If you use repository environments to control access to secrets and variables, you need only pass the name of the environment holding the variables and secrets:

```yaml
  deploy:
    needs: build_and_test
    permissions:
      issues: write
      contents: read
      pull-requests: write
    uses: guidion-digital/terrappy/.github/workflows/tfc-deploy.yaml@CHECK_FOR_LATEST_TAG
    with:
      environment_name: acc
    secrets: inherit
```

Note that the `acc` environment in the example above must contain the variables `organization` and `workspace`, along with the secret `tfc_api_token`. If you provide both `environment_name` and inputs, the values from the inputs win. There is one difference in requirements if using the enterprise version of the workflow, which is detailed below.

## Github Free-Plan Approvals

When on a non-enterprise Github plan, you may use [this version of the re-usable workflow](.github/workflows/tfc-deploy.yaml). If `approvers` is provided, it will display a Terraform plan that needs to be approved via an automatically created Github issue. Bear in mind that the approval job will continue running for a maximum of 6 hours, until the deployment is approved. The cheapest runner costs $2.88 every 6 hours.

## Github Enterprise Approvals

Github Enterprise has a the above feature built in, via deployment approvals. You can then use [the enterprise version of the re-usable workflow](.github/workflows/tfc-deploy-enterprise.yaml). The only difference in requirements are these two variables (either as inputs or in the environment):

- `tfc_planner_api_token` — This token must at minimum have the `plan` permission on the TFC workspace
- `environment_name` — An environment containing `tfc_api_token` which has is a TFC token with `apply` permission on the workspace

The Terraform plan is run with the token from `tfc_planner_api_token`, and the apply is run with the token from `tfc_api_token`. If you then set the environment specified in `environment_name` to require approvals from a trusted list, you will have a protected deploy to that environment.

## No Approvals

If you'd prefer to "do it live!" and have no approval process, the enterprise version will still work for you on the free plan (since you will not be able to set approvers). You can also the free version of the workflow, and simply not supply the `approvers` input.

If you want to avoid approvals on the enterprise plan, simply do not set required reviewers on the environment you're deploying to.
