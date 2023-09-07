#!/bin/sh
set -e

GIT_USER=${GIT_USER:-nfyxhan}
GIT_EMAIL=${GIT_EMAIL:-nfyxhan@163.com}

GO_VERSION=${GO_VERSION:-1.18.10}
GO111MODULE=${GO111MODULE:-on}
GOPROXY=${GOPROXY:-https://goproxy.cn}

KUBE_VERSION=${KUBE_VERSION:-v1.24.15}
HELM_VERSION=${HELM_VERSION:-v3.6.3}

NODEJS_VERSION=${NODEJS_VERSION:-v14.21.3}

CODE_SERVER_VERSION=${CODE_SERVER_VERSION:-4.16.1}

GLBC_VERSION=${GLBC_VERSION:-glibc-2.18}

function install_base_tools() {
  # base tools
  yum update -y
  yum install -y \
    curl  net-tools  wget bash-completion jq unzip \
    make gcc graphviz \
    nginx openssh-server \
    epel-release
  # date
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
    echo "Asia/Shanghai" > /etc/timezone
  # font
  wget https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/OTF/SimplifiedChinese/SourceHanSansSC-Light.otf
    mkdir -p /usr/share/fonts/chinese/
    mv SourceHanSansSC-Light.otf /usr/share/fonts/chinese/SourceHanSansSC-Light.otf
    fc-cache -fv
    localedef -c -f UTF-8 -i zh_CN zh_CN.utf-8
    locale
}

function install_git2() {
  yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y
  yum install -y git
  git config --global user.name "${GIT_USER}"
  git config --global user.email "${GIT_EMAIL}"
  echo 'export LESSCHARSET=utf-8' >> ${BASH_RC}
  ssh-keygen -f ~/.ssh/id_rsa -N ''
}

function install_vim8() {
  yum install -y vim
  rm -rf ~/.vim
  git clone https://github.com/nfyxhan/vim.git
  mv vim ~/.vim
  vim +PlugClean[!] +PlugUpdate +qa
  echo "alias vi='vim '" >>  ${BASH_RC}
}

function install_chrome() {
  yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
  yum install chromedriver -y
}

function install_go() {
    wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz
    rm -rf /usr/local/go
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz
    rm -f go${GO_VERSION}.linux-amd64.tar.gz
    echo 'export PATH=$PATH:/usr/local/go/bin:${GOPATH}/bin:${HOME}/go/bin:/data/bin' >>  ${BASH_RC}
    echo "export GOPROXY=${GOPROXY}" >>  ${BASH_RC}
    echo "export GO111MODULE=${GO111MODULE}" >>  ${BASH_RC}
    source ${BASH_RC}
    go install golang.org/x/tools/cmd/goimports@v0.11.1
    go install golang.org/x/tools/gopls@v0.11.0
    go install github.com/go-delve/delve/cmd/dlv@v1.21.0
    go install github.com/swaggo/swag/cmd/swag@v1.8.9
    go install github.com/golang/mock/mockgen@v1.6.0
    go install golang.org/x/tools/cmd/stringer@v0.3.0
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1
    rm -rf ${HOME}/go/pkg ${HOME}/.cache/go-build
}

function install_kubectl() {
  curl -Lo ./kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl
  chmod +x kubectl
  mv ./kubectl /usr/local/bin/
  echo 'source <(kubectl completion bash)' >>  ${BASH_RC}
}

function install_helm() {
  wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz
  tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz
  mv linux-amd64/helm /usr/local/bin/helm
  echo 'source <(helm completion bash)' >>  ${BASH_RC}
  rm -rf linux-amd64 helm-${HELM_VERSION}-linux-amd64.tar.gz
}

function install_code_server() {
    rpm -i https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-amd64.rpm
    all='golang.go \
    mhutchie.git-graph \
    alphabotsec.vscode-eclipse-keybindings \
    vscodevim.vim' ; \
    for i in $all ; do code-server --install-extension $i ; done
}

function install_nodejs() {
  wget https://nodejs.org/download/release/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz
  tar -xvf node-${NODEJS_VERSION}-linux-x64.tar.gz
  mv node-${NODEJS_VERSION}-linux-x64 /usr/local/nodejs
  echo 'export PATH=$PATH:/usr/local/nodejs/bin' >>  ${BASH_RC}
  rm -rf node-${NODEJS_VERSION}-linux-x64.tar.gz     
} 

function install_glibc() {
  wget https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${GLBC_VERSION}.tar.gz
  tar -zxvf  ${GLBC_VERSION}.tar.gz
  cd ${GLBC_VERSION}
  mkdir build
  cd build/
  ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin
  make -j 8
  make install
  cd ../.. && rm -rf ${GLBC_VERSION} ${GLBC_VERSION}.tar.gz
}

function clean_all() {
    yum clean all
}

all='install_base_tools
install_git2
install_vim8
install_chrome
install_go
install_kubectl
install_helm
install_code_server
install_nodejs
#install_glibc
clean_all
'
for i in $all ;do 
   echo "$i ..."
   $i
   echo "$i done"
done 