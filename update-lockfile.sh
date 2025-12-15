#!/bin/bash
# With the new build system with manifests in the target directory, we broke running
# rpm-lockfile-prototype uninstalled. What we should probably do is require it be
# run from the bootc container itself, but that'd have some circularity and this is a
# quick hack to keep it working.
set -xeuo pipefail
td=$(mktemp -d)
./install-manifests ${td}
cp rpms.*.yaml *.repo ${td}
cd ${td}
rpm-lockfile-prototype rpms.in.yaml
cd -
cp ${td}/rpms.lock.yaml .
rm -rf ${td}
