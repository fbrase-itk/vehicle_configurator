# 9. OIDC federation from GitHub to Azure

Date: 2025-04-12

## Status

Accepted

## Context

`azure-deploy.yml` needs to update the three Container Apps after a
successful image build. The standard pattern (storing a service
principal client secret in `secrets.AZURE_CREDENTIALS`) has two
problems:

- a long-lived credential in the repo is a compliance and rotation
  burden, and
- any workflow from any ref can use it — there is no built-in way to
  scope it to `refs/heads/main`.

## Decision

Use **workload identity federation**. An Azure AD app registration
(`gh-vehicle-configurator-deployer`) trusts the GitHub OIDC issuer for
the subject
`repo:fbrase-itk/vehicle_configurator:ref:refs/heads/main`. The
workflow's `id-token: write` permission requests a short-lived JWT,
which `azure/login@v2` exchanges for an Azure access token.

The bootstrap is automated: `azure/00-bootstrap-oidc.sh` creates the
app registration, its service principal, the Contributor role
assignment scoped to the RG, the federated credential, and pushes the
`AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID` values
as GitHub repo secrets via `gh secret set`.

## Consequences

- **No long-lived credential** can deploy to Azure — only a workflow
  running on the configured branch can.
- The three `AZURE_*_ID` values stored in GitHub are **identifiers**,
  not secrets; they are safe to expose but stored as secrets anyway
  for consistency with the `azure/login` action's input shape.
- Rotating access = revoking the federated credential (or the app
  registration). No secret rotation needed.
- Extending trust to additional branches or tags = adding a second
  federated credential with a different subject.
