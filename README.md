Step Id: 290
# Bluefin Bootc Base Image

This repository defines the **Bluefin LTS** base image, built using the `bootc` architecture.

It uses the [Fedora bootc base-image](https://gitlab.com/fedora/bootc/base-images) as a reference implementation via git submodule.

## Features

- **Declarative Configuration**: Packages and configuration are defined in `bluefin.yaml`.
- **Bluefin Parity**: Includes packages, COPRs, and system files from the Bluefin project.
- **Bootc Compatible**: Built as a bootable OCI image.

## Building Locally

This build uses **nested containerization** (running `rpm-ostree` inside a container), which requires privileged capabilities.

Run the following command in this directory:

```bash
podman build \
  --security-opt=label=disable \
  --cap-add=all \
  --device /dev/fuse \
  -t localhost/bluefin-bootc:latest .
```

### Why Privileged?

The build process involves:
1.  Creating a container (`rpm-ostree` environment).
2.  Running `bubblewrap` (bwrap) inside that container to sandbox the filesystem creation.
3.  Mounting filesystems via FUSE.

Standard unprivileged builds will fail with `bwrap` permission errors.

## Structure

- **`bluefin.yaml`**: Main manifest listing packages and groups.
- **`includes/bluefin-base.yaml`**: Base OS configuration.
- **`system_files/`**: Bluefin system configuration files (copied to `/target-rootfs`).
- **`build.sh`**: The build script executed inside the container.
