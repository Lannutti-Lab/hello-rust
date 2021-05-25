#!/bin/sh
PROJECT_NAME='hello-rust'

ctr=$(buildah from rust:1-alpine)
buildah run $ctr /bin/sh -c '\
    mkdir -p /usr/local/src/${PROJECT_NAME} && \
    cargo build'
