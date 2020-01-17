lib_names := $(shell cut -d, -f1 libraries.csv | tr '\n' ' ')
makefiles := $(patsubst %,build/%/Makefile,$(lib_names))

export pkg_version := $(shell head -n1 versions.txt)
export pkg_rel := $(shell tail -n1 versions.txt)

export PROJECT_DIR := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export TEMPLATE_DIR := $(PROJECT_DIR)/template
export BUILD_DIR := $(PROJECT_DIR)/build

# Porcelain targets

all: $(lib_names)
$(lib_names): %: %-pkg
clean: $(addsuffix -clean,$(lib_names))

# Recursive Makefile generation

$(makefiles): build/%/Makefile: template/tpl_Makefile
	@mkdir -p $(dir $@)
	@lib_name=$* envsubst < $< > $@

# Recursive Makefile rules

steps = pkgbuild install-script pkg srcinfo publish


define step_template =
$(1): $$(addsuffix -$(1),$$(lib_names))
$$(addsuffix -$(1),$$(lib_names)): %-$(1): build/%/Makefile
	$$(MAKE) -C $$(dir $$<) $(1)
endef

$(foreach step,$(steps),$(eval $(call step_template,$(step))))

# Rules

build/.gitignore:
	@mkdir -p build
	@echo "*" > $@

build/optdepends.txt: libraries.csv build/.gitignore
	@echo "\"sweethome3d: Models rendering\"" > $@
	@echo "$(patsubst %,\"sweethome3d-3dmodels-%: More 3D models\",$(lib_names))" | sed 's/" /"\n/g' >> $@

%-clean:
	rm -fr ./build/$*
