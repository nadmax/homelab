dir := "opentofu"

tofu-init:
    @tofu -chdir={{dir}} init

tofu-validate:
    @tofu -chdir={{dir}} validate

tofu-plan:
    @tofu -chdir={{dir}} plan

tofu-apply flag="":
    @if [ "{{flag}}" = "-y" ]; then \
        tofu -chdir={{dir}} apply --auto-approve; \
    else \
        tofu -chdir={{dir}} apply; \
    fi

tofu-destroy flag="":
    @if [ "{{flag}}" = "-y" ]; then \
        tofu -chdir={{dir}} destroy --auto-approve; \
    else \
        tofu -chdir={{dir}} destroy; \
    fi

tofu-clean:
    @cd {{dir}} && rm -f .*.lock* terraform*


generate-passwd:
    @echo "Enter your password (input will be hidden):"
    @HASHED=$(mkpasswd --method=SHA-512 --rounds=4096) && \
    printf "%s" "$HASHED" > opentofu/.passwd && \
    echo "Password hash saved to opentofu/.passwd"

tofu-all flag="": generate-passwd tofu-init tofu-validate tofu-plan tofu-apply