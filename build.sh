#!/usr/bin/env bash
GIT_EMAIL="stmuraka@us.ibm.com"
GIT_NAME="Shaun's IKS-Client update"
IMAGE_NAME="update-iks-client"
docker build --build-arg GIT_EMAIL="${GIT_EMAIL}" --build-arg GIT_NAME="${GIT_NAME}" -t ${IMAGE_NAME} .
