import 'justfiles/ansible.just'
import 'justfiles/tofu.just'
import 'justfiles/tools.just'
import 'justfiles/vms.just'

run-scenario: install-tools setup-inventory setup-vault update-packages setup-k8s

clean:
    @rm -f \
    .os-type \
    .vault_pass \
    opentofu/.passwd \
    opentofu/.terraform.lock* \
    opentofu/terraform.tfstate*