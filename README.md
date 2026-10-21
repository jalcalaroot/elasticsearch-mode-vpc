# Amazon Elasticsearch Service Domain in a VPC — Terraform

Terraform configuration that creates a single-node Amazon Elasticsearch Service (now Amazon OpenSearch Service) domain inside an existing VPC subnet, with its own security group.

> **Status:** legacy reference (2020), not actively maintained. Review and update before using. Written for **Terraform 0.11** (`"${...}"` interpolation, `type = "string"`, quoted `depends_on`, `advanced_options` as a block) and the pre-3.x AWS provider.

## Architecture

- `aws_security_group.elastic-sg` (`<name>-sg`) in the given VPC — ingress TCP **9200** and **9300** from `0.0.0.0/0`, all egress.
- `aws_iam_service_linked_role.es` — the `es.amazonaws.com` service-linked role required for VPC domains (creation fails if it already exists in the account; import or remove it in that case).
- `aws_elasticsearch_domain.main`
  - Elasticsearch **7.4**, one instance, no dedicated masters, no zone awareness.
  - `vpc_options`: one subnet (`subnetid_1`) and the security group above.
  - EBS `gp2` storage of `volume_size` GiB.
  - `advanced_options`: `rest.action.multi.allow_explicit_index = true`.
  - Access policy allowing `es:*` to `"AWS": ["*"]` on the domain.

The AWS provider is declared in `var.tf` and configured from `access_key` / `secret_key` / `region`.

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `access_key` | AWS access key ID (avoid — see Security notes) | — |
| `secret_key` | AWS secret access key (avoid — see Security notes) | — |
| `region` | AWS region, e.g. `us-east-1` or `eu-west-1` | — |
| `elastic_search_name` | Domain name (also used for the SG name) | — |
| `instance_type` | e.g. `t2.small.elasticsearch` (dev) or `m5.large.elasticsearch` (prod) | — |
| `id_account` | AWS account ID used in the access policy ARN (`<AWS_ACCOUNT_ID>`) | — |
| `volume_size` | EBS volume size in GiB, e.g. `30` | — |
| `vpc_id` | Existing VPC ID (`<VPC_ID>`) | — |
| `subnetid_1` | Existing subnet ID for the domain (`<SUBNET_ID>`) | — |

## Usage

```bash
terraform init
terraform apply \
  -var region=us-east-1 \
  -var elastic_search_name=<DOMAIN_NAME> \
  -var instance_type=t2.small.elasticsearch \
  -var id_account=<AWS_ACCOUNT_ID> \
  -var volume_size=30 \
  -var vpc_id=<VPC_ID> \
  -var subnetid_1=<SUBNET_ID>
```

The endpoint is only reachable from inside the VPC (or via VPN/bastion). Prefer an AWS profile or environment credentials over `access_key`/`secret_key`.

## Security notes

- The security group opens 9200/9300 to `0.0.0.0/0`; inside a VPC this means "anything that can route to the subnet". Restrict it to the VPC CIDR or to client security groups. (Port 9300 is not used by the managed service.)
- The access policy grants `es:*` to `*`, so network reachability is the only control. Scope it to IAM principals.
- No encryption at rest, node-to-node encryption, HTTPS enforcement or fine-grained access control.
- Single node in a single subnet/AZ — no high availability.
- Credentials as Terraform variables, local state only, outdated Elasticsearch 7.4 / `aws_elasticsearch_domain` (use `aws_opensearch_domain` today).

## Cleanup

```bash
terraform destroy   # with the same -var values used for apply
```

The service-linked role is destroyed too; that fails if other Elasticsearch/OpenSearch domains in the account still use it.

## License

MIT — see [LICENSE](LICENSE).
