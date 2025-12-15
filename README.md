Step Id: 290
# Bluefin/Aurora OSTree Build System

The goal of this project is to shift the build system for **Bluefin** and **Aurora** (including **DX** and **Nvidia** variants) to a standardized **OSTree-based** composition model.

This repository defines the base images, built using the `bootc` architecture and composed via `rpm-ostree`.

It uses the [Fedora bootc base-image](https://gitlab.com/fedora/bootc/base-images) as a reference implementation via git submodule.

## Features

- **Declarative Configuration**: Packages and configuration are defined in `bluefin.yaml`.
- **Bluefin Parity**: Includes packages, COPRs, and system files from the Bluefin project.
- **Bootc Compatible**: Built as a bootable OCI image.

## Building Locally

This build uses **nested containerization** (running `rpm-ostree` inside a container), which requires privileged capabilities.

Run the following command in this directory:

### Bluefin (GNOME) - Default

```bash
podman build \
  --security-opt=label=disable \
  --cap-add=all \
  --device /dev/fuse \
  -t localhost/bluefin-bootc:latest .
```

### Aurora (KDE)

```bash
podman build \
  --build-arg MANIFEST=kde \
  --security-opt=label=disable \
  --cap-add=all \
  --device /dev/fuse \
  -t localhost/aurora-bootc:latest .
```

### Why Privileged?

The build process involves:
1.  Creating a container (`rpm-ostree` environment).
2.  Running `bubblewrap` (bwrap) inside that container to sandbox the filesystem creation.
3.  Mounting filesystems via FUSE.

Standard unprivileged builds will fail with `bwrap` permission errors.

## Structure

- **`gnome.yaml`**: Main manifest for Bluefin (GNOME).
- **`kde.yaml`**: Main manifest for Aurora (KDE).
- **`common-base.yaml`**: Shared base configuration for all variants.
- **`includes/bluefin-base.yaml`**: Minimal CentOS base configuration.
- **`system_files/`**: System configuration files.
    - **`shared/`**: Files common to all variants.
    - **`bluefin/`**: Files unique to Bluefin.
    - **`aurora/`**: Files unique to Aurora.
- **`build.sh`**: The build script executed inside the container.
