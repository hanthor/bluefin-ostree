# SPDX-License-Identifier: MIT

# Set a default for some recipes
default_variant := "gnome"

# Just doesn't have a native dict type, but quoted bash dictionary works fine
pretty_names := '(
    [gnome]="Bluefin (GNOME)"
    [kde]="Aurora (KDE)"
)'

# Default is to only validate the manifests
all: validate

# Basic validation to make sure the manifests are not completely broken
validate:
    ./ci/validate

# Build a variant using podman
build variant=default_variant:
    #!/bin/bash
    set -euo pipefail
    
    declare -A pretty_names={{pretty_names}}
    variant={{variant}}
    variant_pretty=${pretty_names[$variant]-}
    if [[ -z $variant_pretty ]]; then
        echo "Unknown variant: $variant"
        exit 1
    fi

    echo "Building ${variant_pretty}..."
    
    # Determine manifests arg based on variant
    # Bluefin (gnome) uses default args (MANIFEST=gnome)
    # Aurora (kde) uses MANIFEST=kde
    
    ARGS=(
        "--security-opt=label=disable"
        "--cap-add=all"
        "--device" "/dev/fuse"
        "-v" "${PWD}:/buildcontext"
        "-t" "localhost/${variant}-bootc:latest"
    )
    
    if [[ "$variant" == "kde" ]]; then
        ARGS+=("--build-arg" "MANIFEST=kde")
    elif [[ "$variant" == "gnome" ]]; then
        # Explicitly set for clarity, though it's default
        ARGS+=("--build-arg" "MANIFEST=gnome")
    fi
    
    sudo podman build "${ARGS[@]}" .

# Build all variants
build-all:
    just build gnome
    just build kde
