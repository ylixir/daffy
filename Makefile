TARGETS = dist/Daffy.toc dist/main.lua
INSTALL_DIR = $(WOW_DIR)/_retail_/Interface/Addons/Daffy/
.PHONY: build install uninstall clean

build: $(TARGETS)

install: build
	mkdir -p "$(INSTALL_DIR)"
	cp -r dist/. "$(INSTALL_DIR)"

uninstall:
	rm -rf "$(INSTALL_DIR)"

clean:
	rm -rf dist

dist/Daffy.toc: dist src/Daffy.toc
	cp src/Daffy.toc dist/Daffy.toc

dist/%.lua: dist src/%.lua
	cp "src/$(@F)" "$@"

dist:
	mkdir dist
