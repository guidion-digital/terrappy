If you use Github Actions workflows, you can make use of the [Terrappy re-usable workflow](.github/workflows/tfc-deploy.yaml).

If you'd like to pass the required variables and secrets via inputs, you can do so like this:

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

Note that the `acc` environment in the example above must contain the variables `organization` and `workspace`, along with the secret `tfc_api_token`. If you provide both `environment_name` and inputs, the values from the inputs win.

Currently, if `approvers` is given it will display a Terraform plan that needs to be approved (via an automatically created Github issue). This may change in future as other approval processes are being looked into. Bear in mind that the approval job will continue running for a maximum of 6 hours, until the deployment is approved. The cheapest runner costs $2.88 every 6 hours.
