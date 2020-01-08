
version = $(shell cat version.txt)
lib_names = $(shell cut -d, -f1 libraries.csv | tr '\n' ' ')

makefiles = $(patsubst %,build/%/Makefile,$(lib_names))

# Porcelain targets

all: $(lib_names)
$(lib_names): %: %-pkg
$(addsuffix -PKGBUILD,$(lib_names)): %-PKGBUILD: build/%/PKGBUILD

# Makefile generation

include $(makefiles)
$(makefiles): build/%/Makefile: template/tpl_Makefile build/%/.gitignore
	@lib_name=$* envsubst < $< > $@

# Rules

build/.gitignore:
	@mkdir -p build
	@echo "*" > $@

build/%/.gitignore: build/.gitignore
	@mkdir -p build/$*
	@echo "*" > $@

build/optdepends.txt: libraries.csv build/.gitignore
	@echo "\"sweethome3d: Models rendering\"" > $@
	@echo "$(patsubst %,\"sweethome3d-3dmodels-%: More 3D models\",$(lib_names))" | sed 's/" /"\n/g' >> $@

build/%/PKGBUILD: ./template/PKGBUILD.gen template/tpl_PKGBUILD build/optdepends.txt build/%/.gitignore
	$< $* $@

clean: $(addsuffix -clean,$(lib_names))

%-clean:
	rm -fr ./build/$*
