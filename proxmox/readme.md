# Production Grade Proxmox setup

The goal of this test template is to roll out a production ready proxmox environment using stackweaver. Since stackweaver is only the orchestraton backend this configuration can be packed into a module later for production usage is I ever find myself in need of this.

## Architecture

I'll try to shoot for the best security / automation I can possibly get out of this [community provider](https://registry.terraform.io/providers/bpg/proxmox/latest/docs)

### 2 phase design

1. Use password based auth to bootstrap service account with api key and correct access rights found in [passwd](./passwd/) folder
2. Use the configured service account to create a production ready VM deployment setup using cloud init integration and ubuntu cloud vms or maybe even arch depending on the cloud init integration there. Use the following resources to get a lay of the land:
 - https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_file
 - https://registry.terraform.io/providers/bpg/proxmox/latest/docs/guides/cloud-init
 - https://registry.terraform.io/providers/bpg/proxmox/latest/docs/resources/virtual_environment_vm
