IMAGE ?= ns3-fedora-toolchain
TAG   ?= latest
WINPATH := $(subst \,/,$(CURDIR))

#---------- Build the Docker image --------------------------------
build:
	@echo Building image $(IMAGE):$(TAG)
	docker build -t $(IMAGE):$(TAG) .

#---------- Run an interactive container --------------------------
run: build
	docker run --rm -it -e DISPLAY=$(DISPLAY) -v /tmp/.X11-unix:/tmp/.X11-unix -v "$(WINPATH):/workspace" --name ns3-dev $(IMAGE):$(TAG)

# Convenience alias
shell: run

#---------- Remove image ------------------------------------------
clean:
	@docker image rm -f $(IMAGE):$(TAG) 2>NUL || true

.PHONY: build run shell clean
