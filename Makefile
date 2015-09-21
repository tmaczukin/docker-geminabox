version = latest
name = geminabox
vendor = tmaczukin
image = $(vendor):$(name)

build:
	@docker build --rm -t $(image):$(version) .
	@docker tag -f $(image):$(version) $(image):latest
