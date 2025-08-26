setup-inventory:
    @tofu -chdir={{dir}} output -json vm_ipv4_addresses > ansible/inventory/inventory.json

setup-vault-pass:
    @if [ -f .vault_pass ]; then \
        echo "File .vault_pass already exists. Aborting."; \
        exit 1; \
    fi

    @echo "Enter your user password (input will be hidden):"
    @read -s PASSWORD && printf "%s" "$PASSWORD" > .vault_pass && chmod 600 .vault_pass && \
    echo ".vault_pass file created with user password."

setup-vault: setup-vault-pass
    @if [ -f ansible/playbooks/vaults/vault ]; then \
        echo "File ansible/playbooks/vaults/vault already exists. Aborting."; \
        exit 1; \
    fi

    @mkdir -p ansible/playbooks/vaults
    @echo "Enter the remote user password (used for sudo, input will be hidden):"
    @read -s USER_PASSWORD && \
    echo "ansible_become_pass: \"$USER_PASSWORD\"" > /tmp/vault_plain.yml && \
    ansible-vault encrypt --encrypt-vault-id default --vault-password-file .vault_pass \
        --output ansible/playbooks/vaults/vault /tmp/vault_plain.yml && \
    rm /tmp/vault_plain.yml && \
    echo "Vault created at ansible/playbooks/vaults/vault"

k8s:
    @ansible-playbook ansible/playbooks/k8s.yaml

update-packages:
    @ansible-playbook ansible/playbooks/update_packages.yaml

ansible-lint:
    @ansible-lint ansible/