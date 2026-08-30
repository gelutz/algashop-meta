GRADLE_ARGS ?=

MICROSERVICES := $(CURDIR)/microservices
PRODUCT_CATALOG := $(MICROSERVICES)/product-catalog
ORDERING := $(MICROSERVICES)/ordering

STUBS_DIR := $(PRODUCT_CATALOG)/build/stubs/META-INF/com.lutz.algashop/product-catalog/0.0.1-SNAPSHOT/mappings
ORDERING_STUBS_DIR := $(ORDERING)/src/test/resources/wiremock/product-catalog/mappings

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@grep -hE '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-22s\033[0m %s\n", $$1, $$2}'

.PHONY: stubs
stubs: ## Generate product-catalog WireMock stubs from its contracts
	cd $(PRODUCT_CATALOG) && ./gradlew generateClientStubs $(GRADLE_ARGS)

# The ordering ITs start WireMock in-process against these checked-in files, so
# a contract change only reaches them once it is copied across.
.PHONY: sync-stubs
sync-stubs: stubs ## Regenerate stubs and copy them into ordering's test resources
	cp $(STUBS_DIR)/product/findProductByIdV1.json \
	   $(ORDERING_STUBS_DIR)/find-product-by-id.json
	cp $(STUBS_DIR)/product/findProductByIdNotFoundV1.json \
	   $(ORDERING_STUBS_DIR)/find-product-by-id-not-found.json
	@echo "Copied product-catalog stubs into $(ORDERING_STUBS_DIR)"

.PHONY: test
test: ## Run every microservice's test suite
	./run-all-tests.sh $(GRADLE_ARGS)