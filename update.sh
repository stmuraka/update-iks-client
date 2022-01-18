#!/usr/bin/env bash
GITHUB_KEY="update-iks-client.pem"
GITHUB_REPO="stmuraka/IKS-client"
IMAGE_NAME="update-iks-client"
# uncomment for debugging
#docker run -it --rm -e DEPLOY_KEY="$(cat ${GITHUB_KEY})" -e GITHUB_REPO="${GITHUB_REPO}" ${IMAGE_NAME} /bin/sh
docker run --rm -e DEPLOY_KEY="$(cat ${GITHUB_KEY})" -e GITHUB_REPO="${GITHUB_REPO}" ${IMAGE_NAME}
