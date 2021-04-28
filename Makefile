aws_region ?= eu-west-1
aws_profile ?= dev

tf_version := 0.15.1
regula_version := 0.8.0


define access
	$(eval input=$(1))
	AWS_REGION=$(aws_region) aws-vault exec $(aws_profile) -- $(input)
endef

define tf
	$(eval input=$(1))
	tfswitch $(tf_version)
	$(call access, terraform $(input))
endef


hcl_dir := example
plan_tf := plan.tfplan
plan_json := plan.json
conftest:
	$(call tf, -chdir=$(hcl_dir) init)
	$(call tf, -chdir=$(hcl_dir) plan -refresh=false -out=$(plan_tf))
	terraform -chdir=$(hcl_dir) show -json $(plan_tf) >$(plan_json)
	conftest test $(plan_json)

regula_src := github.com/fugue/regula
regula_dest := policy
conftest-prepare:
	$(info Pulling regula library for conftest)
	conftest pull -p $(regula_dest)/ $(regula_src)/conftest
	conftest pull -p $(regula_dest)/regula/lib '$(regula_src)//lib?ref=v$(regula_version)'
	$(info Pulling the rules provided by regula)
	conftest pull -p $(regula_dest)/regula/rules $(regula_src)/rules

regula_image := fugue/regula:latest
output := regula_output.json
regula-direct:
	$(access, \
		docker run -it \
			--volume $(PWD)/$(hcl_dir):/workspace \
			-e AWS_REGION \
			-e AWS_ACCESS_KEY_ID \
			-e AWS_SECRET_ACCESS_KEY \
			-e AWS_SESSION_TOKEN \
			-e AWS_SECURITY_TOKEN \
			$(regula_image) \
			/workspace > $(output) )


cleanup:
	$(info Removing temporary files)
	@rm -fv $(output)
	@rm -fv $(hcl_dir)/$(plan_tf)
	@rm -fv $(plan_json)


prerequistes:
	brew install conftest
	brew install --cask aws-vault
	brew install docker
	brew install warrensbox/tap/tfswitch

cleanup-prerequistes:
	brew uninstall conftest
	brew uninstall aws-vault
	brew uninstall docker
	brew uninstall warrensbox/tap/tfswitch
	brew uninstall make
