# MyDistro: an image-based KDE desktop built on Universal Blue (Fedora Atomic).
#
# Two variants come out of this one file:
#   mydistro         -> BASE_IMAGE=ghcr.io/ublue-os/kinoite-main:latest
#   mydistro-nvidia  -> BASE_IMAGE=<the KDE + NVIDIA Universal Blue image>
# (see README for how to build both in GitHub Actions)

ARG BASE_IMAGE=ghcr.io/ublue-os/kinoite-main:latest

# Build scripts live in a throwaway stage so they don't end up in the image
FROM scratch AS ctx
COPY build_files /

FROM ${BASE_IMAGE}

# Your GitHub username/org, used so the image knows where its NVIDIA twin lives
ARG IMAGE_OWNER=magi5760
ARG IMAGE_NAME=mydistro

# Themes, wallpapers, scripts, services
COPY system_files /

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    IMAGE_OWNER="${IMAGE_OWNER}" IMAGE_NAME="${IMAGE_NAME}" /ctx/build.sh

RUN bootc container lint
