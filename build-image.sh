#!/bin/sh
PROJECT_NAME='hello-rust'
VERSION='0.0.0'

build_ctr=$(buildah from docker.io/rust:1-alpine)
local_src_prefix=$(dirname $(readlink -f "$0"))
container_prefix="/usr/local"
container_bin_prefix="${container_prefix}/bin"
container_src_prefix="${container_prefix}/src/${PROJECT_NAME}"

# Build from source
buildah config --workingdir "${container_src_prefix}" "${build_ctr}"
buildah copy "${build_ctr}" "${local_src_prefix}" "${container_src_prefix}"
buildah run "${build_ctr}" /bin/sh -c "apk add --no-cache git musl-dev && git clean -xfd && cargo build --release"

# Copy executable from build stage to production stage
production_ctr=$(buildah from docker.io/alpine)
buildah copy --from "${build_ctr}" "${production_ctr}" "${container_src_prefix}/target/release/${PROJECT_NAME}" "${container_bin_prefix}"
buildah config --cmd "${PROJECT_NAME}" "${production_ctr}"

# Save the production image
buildah commit "${production_ctr}" "${PROJECT_NAME}:${VERSION}"
