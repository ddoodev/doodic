WASMPACK_FLAGS=-t nodejs
OUTPUT=pkg target dist

build: clean
	wasm-pack build $(WASMPACK_FLAGS)

publish: build
	cd pkg
	npm publish

clean: 
	rm -rf $(OUTPUT)