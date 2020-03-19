USERNAME:=is217175
DIRS:=monitoring bugged logging
TARGETS:=$(shell find $(DIRS) -name Dockerfile -exec sed -n 's/LABEL imagename=\"\(.*\)\" version=\"\(.*\)\"/\1/p' {} \;)

DOCKERFILE=$(shell find $(DIRS) -name Dockerfile -exec grep -rl "imagename=\"$@\"" {} \;)
VERSION=$(shell find $(DIRS) -name Dockerfile -exec sed -n 's/LABEL imagename=\"$@\" version=\"\(.*\)\"/\1/p' {} \;)

all: $(TARGETS)

$(TARGETS):
ifndef pushonly
	@echo "\n\e[92;1mBuilding \e[4m$@\e[24m image\e[0m\n"
	@docker build -t $(USERNAME)/$@:$(VERSION) $(dir $(DOCKERFILE))
endif
ifndef dontpush
	@echo "\n\e[92;1mPushing \e[4m$@\e[24m to hub.dcoker.com.\e[0m\n"
	@docker push $(USERNAME)/$@:$(VERSION)
endif

show:
	@echo "\n\e[92;1mValid targets:\e[0m $(TARGETS)\n"

help:
	@echo ""
	@echo "  Usage:"
	@echo "    make <target> [<options>=...]"
	@echo ""
	@echo "  Targets:"
	@echo "    all                  - build all images and push it to hub.docker.com"
	@echo "    show                 - show all available images in project"
	@echo "    <image> [<image>...] - build specified images and push it to hub.docker.com"
	@echo "    help                 - show this help"
	@echo ""
	@echo "  Options:"
	@echo "    pushonly             - do not build, push only"
	@echo "    dontpush             - do not push, build only"
	@echo ""
	@echo "  Example:"
	@echo "    make ui post comment pushonly=yes - this push ui post and comment images without build"
	@echo ""

.PHONY: all show $(TARGETS) help
