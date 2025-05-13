IMAGE      ?= ns3-fedora-toolchain
TAG        ?= latest

#---------- Build the Docker image --------------------------------
build:
	docker build -t $(IMAGE):$(TAG) .

#---------- Run an interactive container --------------------------
run: build
	docker run --rm -it \
		-e DISPLAY=$(DISPLAY) \
		-v /tmp/.X11-unix:/tmp/.X11-unix \
		-v $(PWD):/workspace \
		--name ns3-dev \
		$(IMAGE):$(TAG)

# Convenience alias
shell: run

#---------- Remove image ------------------------------------------
clean:
	@docker image rm -f $(IMAGE):$(TAG) 2>/dev/null || true
.PHONY: build run shell clean
