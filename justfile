import 'justfiles/ansible.just'
import 'justfiles/tofu.just'
import 'justfiles/tools.just'

help:
  @echo "Available commands:"

  @echo ""
  @echo "=== OpenTofu Commands ==="
  @echo "  tofu-init           - Initialize OpenTofu configuration"
  @echo "  tofu-validate       - Validate OpenTofu configuration"
  @echo "  tofu-plan           - Show OpenTofu execution plan"
  @echo "  tofu-apply [-y]     - Apply OpenTofu changes; use -y for auto-approve"
  @echo "  tofu-destroy [-y]   - Destroy OpenTofu-managed resources; -y for auto-approve"
  @echo "  tofu-show           - Display full OpenTofu state in human-readable form"
  @echo "  tofu-output         - Output OpenTofu VM IP addresses in JSON"
  @echo "  tofu-clean          - Clean OpenTofu lock, state and temp files"
  @echo "  tofu-provide        - Run full OpenTofu provisioning workflow"

  @echo ""
  @echo "=== Ansible & Vault ==="
  @echo "  setup-inventory     - Export VM IPs from OpenTofu for Ansible inventory"
  @echo "  setup-vault-pass    - Create Ansible vault password file (.vault_pass)"
  @echo "  setup-vault         - Create encrypted Ansible vault file with sudo password"
  @echo "  ansible-lint        - Run ansible-lint on the playbooks directory"
  @echo "  k8s                 - Run Kubernetes cluster setup playbook"
  @echo "  update-packages     - Run package update playbook on VMs"

  @echo ""
  @echo "=== Tool Installation ==="
  @echo "  detect-os           - Detect operating system type (Debian or RHEL)"
  @echo "  install-opentofu    - Install OpenTofu package based on detected OS"
  @echo "  install-ansible     - Install Ansible via pip3 or package manager"
  @echo "  install-virt-packages - Install virtualization packages and enable libvirt"
  @echo "  install-tools       - Detect OS and install required tools (virt, opentofu, ansible)"
  
  @echo ""
  @echo "=== Utilities ==="
  @echo "  generate-passwd     - Generate hashed remote user password (creates .passwd)"

  @echo ""
  @echo "=== Composite Workflows ==="
  @echo "  deploy              - Install tools, provision infra, setup inventory and vault"
  @echo "  init-cluster        - Update packages and run Kubernetes cluster setup"
  @echo "  destroy             - Destroy infrastructure and clean up files"


clean:
    @rm -rf \
    .os-type \
    .vault_pass \
    tofu/.passwd \
    tofu/.terraform.lock* \
    tofu/terraform.tfstate*
    @sudo rm -f ansible/playbooks/vaults/vault

deploy: install-tools tofu-provide setup-inventory setup-vault update-packages k8s
destroy: tofu-destroy clean
