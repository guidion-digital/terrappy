If you use Github Actions workflows, you can make use of the [Terrappy re-usable workflow](.github/workflows/tfc-deploy.yaml).

An example usage where the TFC workspace name and a CSV list of approvers (before `terraform apply`), and the TFC API token, are given via workflow environment variables and secrets could look like this:

```yaml
  deploy:
    needs: build_and_test
    environment: FILL ME IN
    permissions:
      issues: write
      contents: read
      pull-requests: write
    uses: guidion-digital/terrappy/.github/workflows/tfc-deploy.yaml@beta0.0.8
    with:
      organization: guidion
      workspace: ${{ vars.WORKSPACE }}           # From infrastructure repo
      approvers: ${{ vars.TFC_APPROVERS || '' }} # Optional — From code repo
      source_dir: "./dist"                       # Optional
      retention-days: "2"                        # Optional
    secrets:
      tfc_api_token: ${{ secrets.TFC_API_TOKEN }} # From infrastructure repo
```

Currently, if `approvers` is given it will display a Terraform plan that needs to be approved (via an automatically created Github issue) on the `master` branch. This may change in future as other approval processes are being looked into.
