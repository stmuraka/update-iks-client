FROM alpine:latest
MAINTAINER Shaun Murakami (stmuraka@us.ibm.com)
ARG GIT_EMAIL
ARG GIT_NAME
ENV DEPLOY_KEY="" \
    GITHUB_REPO=""
RUN apk update \
 && apk add \
        curl \
        git \
        openssh
RUN git config --global user.email "${GIT_EMAIL}" \
 && git config --global user.name "${GIT_NAME}"
COPY updateLatestVersions.sh /tmp/updateLatestVersions.sh
WORKDIR /tmp
CMD . updateLatestVersions.sh
