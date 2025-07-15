dir := "opentofu"

tofu-init:
    @tofu -chdir={{dir}} init

tofu-validate:
    @tofu -chdir={{dir}} validate

tofu-plan:
    @tofu -chdir={{dir}} plan

tofu-apply:
    @tofu -chdir={{dir}} apply --auto-approve

tofu-output:
    @tofu -chdir={{dir}} output -json vm_ipv4_addresses

tofu-destroy flag="":
    @tofu -chdir={{dir}} destroy --auto-approve; \

tofu-show:
  @tofu -chdir={{dir}} show

tofu-clean:
    rm -f {{dir}}/*.lock {{dir}}/terraform.*

tofu-provide: tofu-init tofu-validate tofu-plan tofu-apply
