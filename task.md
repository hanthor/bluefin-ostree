Step Id: 65
---
title: Create Bluefin Bootc Base Image
status: not-started
---
The goal is to create a new `bootc` base image in `bluefin-ostree` that replicates the `bootc` (CentOS bootc) build process but includes the packages and configuration of Bluefin LTS.

## Checklist
- [x] Initialize `bootc` submodules to ensure reference implementation is complete <!-- id: 0 -->
- [x] Populate `bluefin-ostree` with `bootc` content <!-- id: 1 -->
- [x] Create `bluefin-ostree/includes/bluefin-base.yaml` (modified CentOS base) <!-- id: 2 -->
- [x] Create `bluefin-ostree/bluefin.yaml` (Main Treefile) with Bluefin packages <!-- id: 3 -->
- [x] Configure Repos (EPEL, COPRs) in `bluefin-ostree` <!-- id: 4 -->
- [x] Update `bluefin-ostree/Containerfile` and `build.sh` to use the new manifest <!-- id: 5 -->
- [x] Handle `system_files` copy via postprocess or container layer <!-- id: 6 -->
