dir := "opentofu"

tofu-fmt:
    @tofu -chdir={{dir}} fmt

tofu-init:
    @tofu -chdir={{dir}} init

tofu-validate:
    @tofu -chdir={{dir}} validate

tofu-plan:
    @tofu -chdir={{dir}} plan

tofu-apply:
    @tofu -chdir={{dir}} apply

tofu-applyf: 
    @tofu -chdir={{dir}} apply --auto-approve

tofu-output:
    @tofu -chdir={{dir}} output -json vm_ipv4_addresses

tofu-destroy:
    @tofu -chdir={{dir}} destroy

tofu-destroyf:
    @tofu -chdir={{dir}} destroy --auto-approve

tofu-show:
    @tofu -chdir={{dir}} show

tofu-clean:
    cd {{dir}} && rm -f *.lock terraform.*

generate-passwd:
    @if [ -f opentofu/.passwd ]; then \
        echo "File opentofu/.passwd already exists. Aborting."; \
        exit 1; \
    fi

    @echo "Enter the remote user password (input will be hidden):"
    @HASHED=$(mkpasswd --method=SHA-512 --rounds=4096) && \
    printf "%s" "$HASHED" > opentofu/.passwd && \
    echo "Password hash saved to opentofu/.passwd"

tofu-provide flag="": generate-passwd tofu-init tofu-validate tofu-plan tofu-applyf
