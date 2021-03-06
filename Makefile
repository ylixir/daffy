FENNEL_DIR = ./fennel-0.10.0
FNL = $(FENNEL_DIR)/fennel
TARGETS = dist/Daffy.toc dist/main.lua dist/fennel.lua dist/compat-5.1.lua
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

dist:
	mkdir dist

dist/Daffy.toc: src/Daffy.toc dist
	cp $< $@

dist/fennel.lua: $(FENNEL_DIR)/fennel.lua dist
	printf "local function daffy_fennel_loader()\n" > $@
	cat $< >> $@
	printf "end\n" >> $@
	printf '_G.fennel=daffy_fennel_loader()' >> $@

dist/%.lua: src/%.fnl dist 
	$(FNL) --compile $< > $@
