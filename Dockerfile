FROM centos:7

ENV LANG=zh_CN.utf8

ENV GIT_USER=nfyxhan
ENV GIT_EMAIL=nfyxhan@163.com

ENV GH_VERSION=2.34.0

ENV GO_VERSION=1.18.10
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

ENV GLBC_VERSION=glibc-2.18

ENV KUBE_VERSION=v1.24.15
ENV KUBEBUILDER_VERSION=v3.10.0
ENV HELM_VERSION=v3.6.3
ENV NODEJS_VERSION=v14.21.3
ENV BASH_RC=/etc/bashrc

WORKDIR /home/workspace

### install_base_tools
RUN yum update -y && \
  yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y && \
  yum install -y epel-release && \
  yum install -y \
    curl net-tools wget bash-completion jq unzip fontconfig \
    make gcc \
    git openssh-server \
    vim \
    graphviz \
    nginx \
    && \
  wget -O /etc/yum.repos.d/lbiaggi-vim80-ligatures-epel-7.repo \
    https://copr.fedorainfracloud.org/coprs/lbiaggi/vim80-ligatures/repo/epel-7/lbiaggi-vim80-ligatures-epel-7.repo && \
  yum update -y && \
  yum clean all && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
  mkdir -p /usr/share/fonts/chinese/ && \
  wget -O /usr/share/fonts/chinese/SourceHanSansSC-Light.otf \
    https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/OTF/SimplifiedChinese/SourceHanSansSC-Light.otf && \
    fc-cache -fv && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.utf-8 && \
    locale

### config_git_vim
RUN git config --global user.name "${GIT_USER}" && \
  git config --global user.email "${GIT_EMAIL}" && \
  echo 'export LESSCHARSET=utf-8' >> ${BASH_RC} && \
  ssh-keygen -f ~/.ssh/id_rsa -N '' && \
  rm -rf ~/.vim && \
  git clone https://github.com/nfyxhan/vim.git && \
  mv vim ~/.vim && \
  vim +PlugClean[!] +PlugUpdate +qa && \
  echo "alias vi='vim '" >>  ${BASH_RC}

### install_gh
RUN curl -L https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz | \
  tar -zxv -C /usr/local/ && \
  echo 'export PATH=$PATH:/usr/local/'gh_${GH_VERSION}_linux_amd64'/bin' >>  ${BASH_RC} 

### install_go
RUN curl -L https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz | \
    tar -zxv -C /usr/local/ && \
    echo 'export PATH=$PATH:/usr/local/'go/bin >> ${BASH_RC} && \
    echo 'export PATH=$PATH:${GOPATH}/bin' >>  ${BASH_RC} && \
    source ${BASH_RC} && \
    go install golang.org/x/tools/cmd/goimports@v0.11.1 && \
    go install golang.org/x/tools/gopls@v0.11.0 && \
    go install github.com/go-delve/delve/cmd/dlv@v1.21.0 && \
    go install github.com/swaggo/swag/cmd/swag@v1.8.9 && \
    go install github.com/golang/mock/mockgen@v1.6.0 && \
    go install golang.org/x/tools/cmd/stringer@v0.3.0 && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1 && \
    rm -rf ${HOME}/go/pkg ${HOME}/.cache/go-build

### install_kubectl_helm
RUN curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  echo 'source <(kubectl completion bash)' >>  ${BASH_RC} && \
  curl -Lo /usr/bin/kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/${KUBEBUILDER_VERSION}/kubebuilder_linux_amd64 && \
  chmod +x /usr/bin/kubebuilder && \
  echo 'source <(kubebuilder completion bash)' >>  ${BASH_RC} && \
  mkdir -p /usr/local/helm && \
  curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | \
  tar -zxv -C /usr/local/helm/ --strip-components 1 && \
  echo 'export PATH=$PATH:/usr/local/helm/' >> ${BASH_RC} && \
  echo 'source <(helm completion bash)' >>  ${BASH_RC}

### install_code_server
RUN rpm -i https://github.com/coder/code-server/releases/download/v4.16.1/code-server-4.16.1-amd64.rpm && \
    all='golang.go \
    mhutchie.git-graph \
    alphabotsec.vscode-eclipse-keybindings \
    vscodevim.vim' ; \
    for i in $all ; do code-server --install-extension $i ; done

### install_nodejs
RUN curl -L https://nodejs.org/download/release/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz | \
  tar -zxv -C /usr/local/ && \
  echo 'export PATH=$PATH:/usr/local/'node-${NODEJS_VERSION}-linux-x64'/bin' >>  ${BASH_RC}

### install_chrome
# RUN yum install -y chromedriver && \
#   yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
#   yum clean all

### install_glibc
# RUN curl -L https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${GLBC_VERSION}.tar.gz | \
#   tar -zxv && \
#   cd ${GLBC_VERSION} && \
#   mkdir build && \
#   cd build/ && \
#   ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin && \
#   make -j 8 && \
#   make install && \
#   cd ../.. && rm -rf ${GLBC_VERSION}

ADD ./hack ./hack

ADD ./Dockerfile ./Dockerfile
