Step Id: 67
# Implementation Plan - Bluefin Bootc Base Image

Refactor the `bluefin-ostree` directory to build a Bluefin LTS image using the `bootc` (rpm-ostree) methodology.

## Proposed Changes

### Bluefin Ostree Setup
1.  **Duplicate Bootc Structure**: Copy all files from `ostree-lts/bootc` to `ostree-lts/bluefin-ostree`.
    - Includes `Containerfile`, `build.sh`, `preflight.sh`, `*.repo`, and the `fedora-bootc` directory (as a static copy).
    - Remove `.git` directories to detach from upstream git state.

2.  **Manifest Creation**:
    - Create `bluefin-ostree/includes/bluefin-base.yaml`:
        - Based on `includes/centos-stream.yaml`.
        - Remove `subscription-manager` (as per Bluefin logic).
    - Create `bluefin-ostree/bluefin.yaml`:
        - Include `includes/bluefin-base.yaml`.
        - Define `repos`: EPEL, Multimedia, COPRs (GNOME, ublue-os, nerd-fonts, tailscale).
        - Define `packages`: Consolidate lists from `bluefin-lts/build_scripts/*.sh`.
        - Define `postprocess`: Script to copy `system_files` from `/src` (if using Container methods) or applying configuration.

3.  **Repository Configuration**:
    - Add `.repo` files for `epel`, `tailscale`, etc. into `bluefin-ostree` if we want to reference them by file in `rpms.in.yaml` or `bluefin.yaml`. Or rely on inline definitions/URLs if `rpm-ostree` supports sufficient configuration.
    - *Decision*: Copying `.repo` files is robust.

4.  **System Files**:
    - Copy `ostree-lts/bluefin-lts/system_files` to `ostree-lts/bluefin-ostree/system_files`.
    - Update `bluefin.yaml` postprocess to `cp -r /src/system_files/shared/* /usr/etc/` etc.

5.  **Build Configuration**:
    - Update `bluefin-ostree/Containerfile`:
        - `COPY system_files /src/system_files` (so they are available during build).
        - Set `ARG MANIFEST=bluefin.yaml` (or equivalent).

## Verification Plan

### Automated Tests
- Run `podman build .` in `bluefin-ostree` to verify the image builds.
- Run `bootc container-lint` on the resulting image (if available).
- Inspect the generated OCI archive or local container image to verify Bluefin packages (e.g., `rpm -qa | grep bluefin-logos`).

### Manual Verification
- User can `podman run --rm -it localhost/bluefin-bootc:latest rpm -qa` to verify content.
