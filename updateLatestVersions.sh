#!/bin/sh

set -e

updated=1
update_str="Auto-update Function: "

# Setup SSH for Git
[[ "${DEPLOY_KEY}" == "" ]] && { echo "DEPLOY_KEY must be passed as an enviroment variable"; exit 1; }
[[ "${GITHUB_REPO}" == "" ]] && { echo "GITHUB_REPO must be passed as an enviroment variable"; exit 1; }

# Setup SSH for Git
if [[ "${DEPLOY_KEY}" == "" ]]; then
    echo "DEPLOY_KEY must be passed as an enviroment variable"
    exit 1
fi
keyfile="${HOME}/.ssh/deploy.key"
mkdir -p ~/.ssh
echo "${DEPLOY_KEY}" > ${keyfile}
chmod 600 ${keyfile}
unset DEPLOY_KEY

cat << EOF > ~/.ssh/config
Host github.com
    HostName github.com
    IdentityFile ${keyfile}
    StrictHostKeyChecking no
EOF

# Download code
cd /tmp
git clone git@github.com:${GITHUB_REPO}.git
cd IKS-client

# Get code versions
code_kubectl_version=$(grep '^ARG KUBECTL_VERSION' Dockerfile | cut -d '=' -f2)
#echo "Code kubectl version: ${code_kubectl_version}"
code_calicoctl_version=$(grep '^ARG CALICOCTL_VERSION' Dockerfile | cut -d '=' -f2)
#echo "Code calicoctl version: ${code_calicoctl_version}"
code_helm_version=$(grep '^ARG HELM_VERSION' Dockerfile | cut -d '=' -f2)
#echo "Code helm 2 version: ${code_helm_version}"
code_helm3_version=$(grep '^ARG HELM3_VERSION' Dockerfile | cut -d '=' -f2)
#echo "Code helm 3 version: ${code_helm3_version}"


# Get latest versions
latest_kubectl_version=$(curl -sSL https://storage.googleapis.com/kubernetes-release/release/stable.txt | tr -d 'v')
#echo "Latest kubectl version: ${latest_kubectl_version}"
latest_calicoctl_version=$(curl -sSL https://github.com/projectcalico/calicoctl/releases | grep tree | sed 's/.*\(title=.*"\).*/\1/' | awk '{print $2}' | cut -d '"' -f2 | grep -v 'beta' | awk -F '/' '{print $NF}' | tr -d 'v' | sort -rV | uniq | head -n 1)
#echo "Latest calicoctl version: ${latest_calicoctl_version}"
latest_helm_version=$(curl -sSL https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name' | grep '^v2' | grep -v '-' | tr -d 'v' | sort -V | tail -n 1)
#echo "Latest helm 2 version: ${latest_helm_version}"
latest_helm3_version=$(curl -sSL https://api.github.com/repos/helm/helm/releases | jq -r '.[].tag_name' | grep '^v3' | grep -v '-' | tr -d 'v' | sort -V | tail -n 1)
#echo "Latest helm 3 version: ${latest_helm3_version}"


# Compare kubectl versions
if [[ "${latest_kubectl_version}" != "${code_kubectl_version}"  ]]; then
    echo "Upgrading kubectl ${code_kubectl_version} -> ${latest_kubectl_version}"
    update_str="${update_str}Bumping kubectl version to ${latest_kubectl_version}; "
    sed -ie "s/^ARG KUBECTL_VERSION=${code_kubectl_version}/ARG KUBECTL_VERSION=${latest_kubectl_version}/" Dockerfile
    updated=0
fi
# Compare calicoctl versions
if [[ "${latest_calicoctl_version}" != "${code_calicoctl_version}"  ]]; then
    echo "Upgrading calicoctl ${code_calicoctl_version} -> ${latest_calicoctl_version}"
    update_str="${update_str}Bumping calicoctl version to ${latest_calicoctl_version}; "
    sed -ie "s/^ARG CALICOCTL_VERSION=${code_calicoctl_version}/ARG CALICOCTL_VERSION=${latest_calicoctl_version}/" Dockerfile
    updated=0
fi
# Compare helm 2 versions
if [[ "${latest_helm_version}" != "${code_helm_version}"  ]]; then
    echo "Upgrading helm  2 ${code_helm_version} -> ${latest_helm_version}"
    update_str="${update_str}Bumping Helm 2 version to ${latest_helm_version}; "
    sed -ie "s/^ARG HELM_VERSION=${code_helm_version}/ARG HELM_VERSION=${latest_helm_version}/" Dockerfile
    updated=0
fi
# Compare helm 3 versions
if [[ "${latest_helm3_version}" != "${code_helm3_version}"  ]]; then
    echo "Upgrading Helm 3 ${code_helm3_version} -> ${latest_helm3_version}"
    update_str="${update_str}Bumping Helm 3 version to ${latest_helm3_version}; "
    sed -ie "s/^ARG HELM3_VERSION=${code_helm3_version}/ARG HELM3_VERSION=${latest_helm3_version}/" Dockerfile
    updated=0
fi

# echo "git message: ${update_str}"
# If updated, push updates
if [[ ${updated} -eq 0 ]]; then
    echo "Pushing updates to github.com"
    git add Dockerfile
    git commit -m "${update_str}"
    git push
else
    echo "No updates"
fi
