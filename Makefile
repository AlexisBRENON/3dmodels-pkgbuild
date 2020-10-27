lib_names := $(shell cut -d, -f2 libraries.csv | tr '\n' ' ')
lib_types := $(shell cut -d, -f1 libraries.csv | tr '\n' ' ')
libs := $(join $(addsuffix /,$(lib_types)), $(lib_names))
makefiles := $(patsubst %,build/%/Makefile,$(libs))

export PROJECT_DIR := $(realpath $(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
export TEMPLATE_DIR := $(PROJECT_DIR)/template
export BUILD_DIR := $(PROJECT_DIR)/build

# Porcelain targets

all: $(libs)
$(libs): %: %-pkg
clean: $(addsuffix -clean,$(libs))

# Recursive Makefile generation

$(makefiles): build/%/Makefile: template/tpl_Makefile.mk
	@mkdir -p $(dir $@)
	@lib_name=$$(echo "$*" | cut -d'/' -f2) \
		lib_type=$$(echo "$*" | cut -d'/' -f1) \
		envsubst < $< > $@

# Recursive Makefile rules

steps = pkgbuild install-script pkg srcinfo test publish


define step_template =
$(1): $$(addsuffix -$(1),$$(libs))
$$(addsuffix -$(1),$$(libs)): %-$(1): build/%/Makefile
	$$(MAKE) -C $$(dir $$<) $(1) LIBRARY_DIR=$$(PROJECT_DIR)/$$(dir $$<)
endef

$(foreach step,$(steps),$(eval $(call step_template,$(step))))

# Rules

build/.gitignore:
	@mkdir -p build
	@echo "*" > $@

build/optdepends.txt: libraries.csv build/.gitignore
	@echo "\"sweethome3d: Models rendering\"" > $@
	@echo "$(patsubst %,\"sweethome3d-%: More 3D models\",$(subst /,-,$(filter 3dmodels/%,$(libs))))" | sed 's/" /"\n/g' >> $@
	@echo "$(patsubst %,\"sweethome3d-%: More textures\",$(subst /,-,$(filter textures/%,$(libs))))" | sed 's/" /"\n/g' >> $@

%-clean:
	rm -fr ./build/$*
