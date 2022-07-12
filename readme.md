Repro sample for the non-working cross-platform TF providers.

Environment in which below steps were ran:
- Terraform 1.2.4: as set in `.tool-versions`, installed via `asdf`
- macOS 11.6 on arm64

Steps:

1. Have this in `~/.terraformrc`:
```ini
plugin_cache_dir   = "$HOME/.terraform.d/plugin-cache"
disable_checkpoint = true
```
(If it matters, `TF_PLUGIN_CACHE_DIR` is unset.)

2. init repo with these files
    - .tool-versions
    - main.tf
    - variables.tf

2. run `terraform init`, add `.terraform` to `.gitignore`, and commit `.gitignore` and `.terraform.lock.hcl`
3. run `terraform providers lock -platform=darwin_amd64 -platform=darwin_arm64`, with the goal of adding another platform to the TF lock file, and get this error:

```sh
> terraform providers lock -platform=darwin_amd64 -platform=darwin_arm64
- Fetching hashicorp/kubernetes 2.12.1 for darwin_amd64...
- Obtained hashicorp/kubernetes checksums for darwin_amd64 (signed by HashiCorp)
- Fetching hashicorp/aws 4.22.0 for darwin_amd64...
- Obtained hashicorp/aws checksums for darwin_amd64 (signed by HashiCorp)
- Fetching hashicorp/tls 3.4.0 for darwin_amd64...
- Fetching hashicorp/cloudinit 2.2.0 for darwin_amd64...
╷
│ Error: Could not retrieve providers for locking
│
│ Terraform failed to fetch the requested providers for darwin_amd64 in order to calculate their checksums: some providers could not be installed:
│ - registry.terraform.io/hashicorp/cloudinit: the current package for registry.terraform.io/hashicorp/cloudinit 2.2.0 doesn't match any of the
│ checksums previously recorded in the dependency lock file
│ - registry.terraform.io/hashicorp/tls: the current package for registry.terraform.io/hashicorp/tls 3.4.0 doesn't match any of the checksums
│ previously recorded in the dependency lock file.
```

5. repeat the previous command, but this time specify a specific provider (`hashicorp/aws` in this case): `terraform providers lock -platform=darwin_amd64 -platform=darwin_arm64 hashicorp/aws`. Surprisingly (?) the checksum for `darwin_amd64` platform gets successfully added this time (commit bb94b4b):

```sh
> terraform providers lock -platform=darwin_amd64 -platform=darwin_arm64 hashicorp/aws
- Fetching hashicorp/aws 4.22.0 for darwin_amd64...
- Obtained hashicorp/aws checksums for darwin_amd64 (signed by HashiCorp)
- Fetching hashicorp/aws 4.22.0 for darwin_arm64...
- Obtained hashicorp/aws checksums for darwin_arm64 (signed by HashiCorp)

Success! Terraform has updated the lock file.

Review the changes in .terraform.lock.hcl and then commit to your
version control system to retain the new checksums.
```

6. Yet instaling `cloudinit`'s checksum still fails:
```sh
> terraform providers lock -platform=darwin_amd64 -platform=darwin_arm64 hashicorp/cloudinit
- Fetching hashicorp/cloudinit 2.2.0 for darwin_amd64...
╷
│ Error: Could not retrieve providers for locking
│
│ Terraform failed to fetch the requested providers for darwin_amd64 in order to calculate
│ their checksums: some providers could not be installed:
│ - registry.terraform.io/hashicorp/cloudinit: the current package for
│ registry.terraform.io/hashicorp/cloudinit 2.2.0 doesn't match any of the checksums
│ previously recorded in the dependency lock file.
```