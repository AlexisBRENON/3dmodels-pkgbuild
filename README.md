# 3D Models PKGBUILD

🛏️🌳

> Generates `PKGBUILD` for SweetHome3D assets

🛋️🧑🌴
## Description 📜

SweetHome3D comes with some pre-installed 3D models and textures.
Others can be downloaded and manually installed.
ArchLinux User Repository (AUR) provides a way to make them easy-installable.

This repository contains a set of scripts which generate `PKGBUILD` and install scripts for these assets.

## Installation 📥

Scripts heavily rely on `bash`, `make` and Arch tool (`makepkg`, `namcap`, etc.).
You should install them through `pacman`.

## Usage ▶️

Just execute the main `Makefile` target to build all the packages:

```shell script
make
```

You can also build a single one, by providing its `type` and `name`:

```shell script
# make <type>/<name>
make 3dmodels/scopia
make textures/contributions
```

Then you can publish the generated packages:

```shell script
# Publish all packages
make publish
# Publish only one package
make textures/scopia-publish
```

## Documentation 🔎

Generated libraries are listed in `libraries.csv`.
Each row lists:
  1. **Asset type**: `3dmodels`, `textures`
  2. **Package name**: as published to AUR
  3. **File name**: as published on SourceForge
  4. **Version**: as published on SourceForge
  5. **`pkgrel`**: release number of this version
  6. **SHA1 sum**: of the downloaded assets archive
  7. **Licence**: as reported in the PKGBUILD
