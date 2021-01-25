.PHONY: extract
extract: iid
	rm -rf ./build
	mkdir -p ./build
	podman run --rm $(shell cat iid) | tar xf - -C ./build
	rm iid

iid: Makefile Dockerfile
	podman build --no-cache --iidfile iid .
