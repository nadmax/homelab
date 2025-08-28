import 'justfiles/tofu.just'
import 'justfiles/tools.just'

help:
  @echo "Available commands:"

  @echo ""
  @echo "=== OpenTofu Commands ==="
  @echo "  tofu-init           - Initialize OpenTofu configuration"
  @echo "  tofu-validate       - Validate OpenTofu configuration"
  @echo "  tofu-plan           - Show OpenTofu execution plan"
  @echo "  tofu-apply          - Apply OpenTofu changes"
  @echo "  tofu-destroy        - Destroy OpenTofu-managed resources"
  @echo "  tofu                - Run full OpenTofu provisioning workflow"

  @echo ""
  @echo "=== Tools Installation ==="
  @echo "  install-opentofu    - Install OpenTofu package based on host OS"
  @echo "  install-docker      - Install Docker engine and enable it"
  @echo "  install             - Install required tools (opentofu, docker) based on host OS"

  @echo ""
  @echo "=== Composite Workflows ==="
  @echo "  deploy              - Install tools, and create the lab"
  @echo "  destroy             - Destroy the lab and clean up files"


exec:
    docker exec -it controlplane sh

clean:
    @rm -rf \
    tofu/.terraform.lock* \
    tofu/terraform.tfstate*

deploy: install tofu exec
destroy: tofu-destroy clean
