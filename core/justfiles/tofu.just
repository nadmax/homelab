dir := "tofu"

tofu-init:
    @tofu -chdir={{dir}} init

tofu-validate:
    @tofu -chdir={{dir}} validate

tofu-plan:
    @tofu -chdir={{dir}} plan

tofu-apply:
    @tofu -chdir={{dir}} apply --auto-approve

tofu-destroy:
    @tofu -chdir={{dir}} destroy --auto-approve

tofu: tofu-init tofu-validate tofu-plan tofu-apply
