.PHONY: build
build:
	rpm-ostree compose image --format=ociarchive --initialize --image-config=centos-bootc-config.json centos-stream-tier1.yaml dest.oci-archive

.PHONY: lockfile
lockfile:
ifdef CI
	./update_submodule.sh
endif
	./update-lockfile.sh
