# Variable definition

pkg_version := $(shell grep "^${lib_type},${lib_name}" "${PROJECT_DIR}/libraries.csv" | cut -d, -f4)
pkg_rel := $(shell grep "^${lib_type},${lib_name}" "${PROJECT_DIR}/libraries.csv" | cut -d, -f5)

# Porcelain commands

pkgbuild: PKGBUILD
install-script: sweethome3d-${lib_type}-${lib_name}.install
pkg: sweethome3d-${lib_type}-${lib_name}-$(pkg_version)-$(pkg_rel)-any.pkg.tar.zst
srcinfo: .SRCINFO
test: test_output
commit: .git/refs/heads/master

# Plumbing commands

.git:
	git config --global init.defaultBranch master
	git init .
	git config --local user.name "Alexis BRENON"
	git config --local user.email "brenon.alexis+arch@gmail.com"
	echo "*" > .gitignore
	git remote add origin ssh://aur@aur.archlinux.org/sweethome3d-${lib_type}-${lib_name}.git

PKGBUILD: $(TEMPLATE_DIR)/PKGBUILD.gen $(TEMPLATE_DIR)/${lib_type}/PKGBUILD $(BUILD_DIR)/optdepends.txt
	$< "${lib_type}" "${lib_name}" > $@

sweethome3d-${lib_type}-${lib_name}.install: $(TEMPLATE_DIR)/install.gen $(TEMPLATE_DIR)/${lib_type}/template.install
	$< "${lib_type}" "${lib_name}" > $@

sweethome3d-${lib_type}-${lib_name}-$(pkg_version)-$(pkg_rel)-any.pkg.tar.zst: PKGBUILD sweethome3d-${lib_type}-${lib_name}.install
	makepkg -f
	namcap $@

.SRCINFO: PKGBUILD
	makepkg --printsrcinfo > .SRCINFO

test_output: sweethome3d-${lib_type}-${lib_name}-$(pkg_version)-$(pkg_rel)-any.pkg.tar.zst
	docker build -t 3dmodels-pkgbuild:$(pkg_version)-$(pkg_rel) "${PROJECT_DIR}/docker"
	docker run -t --rm \
		-v $(LIBRARY_DIR):/app -w /app \
		3dmodels-pkgbuild:$(pkg_version)-$(pkg_rel) \
		/root/test.sh $< | tee $@

.git/refs/heads/master: PKGBUILD .SRCINFO sweethome3d-${lib_type}-${lib_name}.install | .git
	git add -f .SRCINFO PKGBUILD sweethome3d-${lib_type}-${lib_name}.install
	git fetch origin master
	git reset --soft FETCH_HEAD
	git commit -m "Version $(pkg_version)-$(pkg_rel)" || true

publish: .git/refs/heads/master
	git push origin master
	touch publish
