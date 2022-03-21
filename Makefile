build: clean
	wasm-pack build

publish: build
	cd pkg
	npm publish

clean: 
	rm -rf pkg target dist