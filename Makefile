WASMPACK_FLAGS=-t nodejs
WASMPACK_RELEASE=$(WASMPACK_FLAGS) --release
OUTPUT=pkg target dist

help:
	@echo 'Doodic Makefile'
	@echo '	@ make build to build'
	@echo '	@ make build-release to create a release build'
	@echo '	@ make publish to publish'
	@echo '	@ make clean to clean rubbish'

build: clean
	wasm-pack build $(WASMPACK_FLAGS)

build-release: clean
	wasm-pack build $(WASMPACK_RELEASE)

publish: build
	cd pkg
	npm publish

clean: 
	rm -rf $(OUTPUT)