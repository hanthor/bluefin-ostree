#!/bin/bash
# See the main Containerfile
set -xeuo pipefail
# Some sanity checks
./preflight.sh

# Put our manifests into the builder image in the same location they'll be in the
# final image.

# Copy custom repositories
cp /src/*.repo /etc/yum.repos.d/

# Copy GPG keys
cp /src/RPM-GPG-KEY-EPEL-10 /etc/pki/rpm-gpg/

./install-manifests
# And embed the rebuild script
# install -m 0755 -t /usr/libexec fedora-bootc/bootc-base-imagectl
# Verify that listing works
# /usr/libexec/bootc-base-imagectl list >/dev/null

# Run the build script in the same way we expect custom images to do, and also
# "re-inject" the manifests into the target, so secondary container builds can use it.
# /usr/libexec/bootc-base-imagectl build-rootfs --reinject --manifest=${MANIFEST} /target-rootfs

# Manual build-rootfs replacement using rpm-ostree
echo "Initializing repo..."
mkdir -p /repo
ostree --repo=/repo init --mode=archive
rpm-ostree compose tree --repo=/repo --cachedir=/workdir --unified-core ${MANIFEST}.yaml
# Determine branch/ref
COMMIT=$(ostree --repo=/repo refs | head -n 1)
echo "Checking out commit $COMMIT..."
ostree --repo=/repo checkout -U $COMMIT /target-rootfs

# Reinject manifests into the target
echo "Reinjecting manifests..."
mkdir -p /target-rootfs/usr/share/doc/bootc-base-imagectl/manifests
cp -r /usr/share/doc/bootc-base-imagectl/manifests/* /target-rootfs/usr/share/doc/bootc-base-imagectl/manifests/

# Inject system files
echo "Injecting system files..."
# Always inject shared
cp -rv /src/system_files/shared/. /target-rootfs/

# Content specific injection
if [[ "${MANIFEST}" == "gnome" ]] || [[ "${MANIFEST}" == "bluefin" ]]; then
    echo "Injecting Bluefin specific files..."
    if [ -d "/src/system_files/bluefin" ]; then
        cp -rv /src/system_files/bluefin/. /target-rootfs/
    fi
elif [[ "${MANIFEST}" == "kde" ]] || [[ "${MANIFEST}" == "aurora" ]]; then
    echo "Injecting Aurora specific files..."
    if [ -d "/src/system_files/aurora" ]; then
        cp -rv /src/system_files/aurora/. /target-rootfs/
    fi
fi

# Arch specific overrides
ARCH=$(uname -m)
if [ -d "/src/system_files_overrides/$ARCH" ]; then
    echo "Injecting overrides for $ARCH..."
    cp -rv "/src/system_files_overrides/$ARCH/." /target-rootfs/
fi
# Now for this we still rely on using a buildah version that predates https://github.com/containers/buildah/issues/5952
rpm-ostree experimental compose build-chunked-oci --bootc --format-version=1 --rootfs /target-rootfs --output oci-archive:/buildcontext/out.ociarchive
