.PHONY: check api-test terraform-fmt

check: terraform-fmt api-test

terraform-fmt:
	terraform fmt -check -recursive infra

api-test:
	cd services/api && pytest

