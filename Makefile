override OPENAPI := node_modules/.bin/redocly
override BUNDLED_SPECS := $(foreach dir,$(wildcard specs/*),dist/$(notdir $(dir)).json)

VERSION = v1

all: $(BUNDLED_SPECS)

$(BUNDLED_SPECS): dist/%.json: specs/%/spec.yaml $(shell find specs/$* -type f)
	@mkdir -p $(dir $@)
	@$(OPENAPI) bundle $< --output $@ --ext json --lint

.PHONY: preview
preview:
	@$(OPENAPI) preview-docs specs/$(VERSION)/spec.yaml --port 8500

.PHONY: lint
lint:
	@$(OPENAPI) lint specs/$(VERSION)/spec.yaml
