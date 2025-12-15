# In order to make a base image as part of a Dockerfile, this container build uses
# nested containerization, so you must build with e.g.
# podman build -v "$(pwd):/buildcontext" --security-opt=label=disable --cap-add=all --device /dev/fuse <...>

# Note that because of how cachi2 manages the repo files, we can't
# do the separate "repos container" pattern.
ARG COMMON_IMAGE_REF=ghcr.io/projectbluefin/common@sha256:d2443dae3b956b5af024e2b4767f20e82a630a47f176391417acecd096e77183
FROM ${COMMON_IMAGE_REF} AS common




# Gather all repo files and keys for bind mounting
FROM quay.io/centos-bootc/centos-bootc:stream10 AS repos
RUN rm -rf /etc/yum.repos.d/*
COPY *.repo /etc/yum.repos.d/
COPY RPM-GPG-KEY* /etc/pki/rpm-gpg/


FROM quay.io/centos-bootc/centos-bootc:stream10 as builder
# skip gpgcheck due to gpgcheck="" in cachi2.repo
# RUN dnf -y --nogpgcheck install rpm-ostree selinux-policy-targeted
ARG MANIFEST=gnome
COPY . /src
COPY --from=common /system_files/shared /src/system_files/shared
COPY --from=common /system_files/bluefin /src/system_files/bluefin
WORKDIR /src
RUN --mount=type=cache,rw,id=bootc-base-image-cache-v2,target=/cache \
    --mount=type=bind,rw,from=repos,src=/,dst=/repos <<EORUN
set -xeuo pipefail
# Put our manifests into the builder image in the same location they'll be in the
# final image.
./install-manifests
# Verify that listing works
/usr/libexec/bootc-base-imagectl list
# Run the build script in the same way we expect custom images to do, and also
# "re-inject" the manifests into the target, so secondary container builds can use it.
/usr/libexec/bootc-base-imagectl build-rootfs \
    --cachedir=/cache --reinject --manifest=${MANIFEST} /repos /target-rootfs
EORUN


# This pulls in the rootfs generated in the previous step
FROM oci-archive:./out.ociarchive
# Need to reference builder here to force ordering. But since we have to run
# something anyway, we might as well cleanup after ourselves.
RUN --mount=type=bind,from=builder,src=.,target=/var/tmp rm -v /buildcontext/out.ociarchive

# Note for now we are also keeping the legacy ostree.bootable label too
# so we can do direct upgrades from old bootc in RHEL 9.4.
LABEL containers.bootc="1" \
      ostree.bootable="1" \
      org.opencontainers.image.version=10 \
      version=10 \
      redhat.version-id=10 \
      bootc.diskimage-builder="quay.io/centos-bootc/bootc-image-builder" \
      redhat.id="centos"
# https://pagure.io/fedora-kiwi-descriptions/pull-request/52
ENV container=oci
# Make systemd the default
STOPSIGNAL SIGRTMIN+3
CMD ["/sbin/init"]
