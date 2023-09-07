FROM centos:7

ENV LANG=zh_CN.utf8

ENV GIT_USER=nfyxhan
ENV GIT_EMAIL=nfyxhan@163.com

ENV GO_VERSION=1.18.10
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

ENV GLBC_VERSION=glibc-2.18

ENV KUBE_VERSION=v1.24.15
ENV HELM_VERSION=v3.6.3
ENV NODEJS_VERSION=v14.21.3
ENV CHROME_DRIVER_VERSION=114.0.5735.90
ENV BASH_RC=/etc/bashrc

WORKDIR /home/workspace

# install base tools
RUN yum update -y && \
  yum install -y epel-release && \
  yum install -y \
    curl net-tools wget bash-completion jq unzip fontconfig \
    make gcc \
    && \
  yum clean all && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
    echo "Asia/Shanghai" > /etc/timezone && \
  wget https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/OTF/SimplifiedChinese/SourceHanSansSC-Light.otf && \
    mkdir -p /usr/share/fonts/chinese/ && \
    mv SourceHanSansSC-Light.otf /usr/share/fonts/chinese/SourceHanSansSC-Light.otf && \
    fc-cache -fv && \
    localedef -c -f UTF-8 -i zh_CN zh_CN.utf-8 && \
    locale

# config git
RUN yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y && \
  yum install -y git openssh-server && \
  yum clean all && \
  git config --global user.name "${GIT_USER}" && \
  git config --global user.email "${GIT_EMAIL}" && \
  echo 'export LESSCHARSET=utf-8' >> ${BASH_RC} && \
  ssh-keygen -f ~/.ssh/id_rsa -N ''

# install vim8 
RUN yum install -y vim && \
  wget -O /etc/yum.repos.d/lbiaggi-vim80-ligatures-epel-7.repo https://copr.fedorainfracloud.org/coprs/lbiaggi/vim80-ligatures/repo/epel-7/lbiaggi-vim80-ligatures-epel-7.repo && \
  yum update -y && \
  yum clean all && \
  rm -rf ~/.vim && \
  git clone https://github.com/nfyxhan/vim.git && \
  mv vim ~/.vim && \
  vim +PlugClean[!] +PlugUpdate +qa && \
  echo "alias vi='vim '" >>  ${BASH_RC}

# install go
RUN yum install -y graphviz \
  yum clean all && \
  wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -f go${GO_VERSION}.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin:${GOPATH}/bin:${HOME}/go/bin:/data/bin' >>  ${BASH_RC} && \
    source ${BASH_RC} && \
    go install golang.org/x/tools/cmd/goimports@v0.11.1 && \
    go install golang.org/x/tools/gopls@v0.11.0 && \
    go install github.com/go-delve/delve/cmd/dlv@v1.21.0 && \
    go install github.com/swaggo/swag/cmd/swag@v1.8.9 && \
    go install github.com/golang/mock/mockgen@v1.6.0 && \
    go install golang.org/x/tools/cmd/stringer@v0.3.0 && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1 && \
    rm -rf ${HOME}/go/pkg ${HOME}/.cache/go-build

# install kubectl
RUN curl -Lo ./kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv ./kubectl /usr/local/bin/ && \
  echo 'source <(kubectl completion bash)' >>  ${BASH_RC}

# install helm
RUN wget https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz && \
  tar -xvf helm-${HELM_VERSION}-linux-amd64.tar.gz && \
  mv linux-amd64/helm /usr/local/bin/helm && \
  echo 'source <(helm completion bash)' >>  ${BASH_RC} && \
  rm -rf linux-amd64 helm-${HELM_VERSION}-linux-amd64.tar.gz

# install code-server
RUN rpm -i https://github.com/coder/code-server/releases/download/v4.16.1/code-server-4.16.1-amd64.rpm && \
  yum install -y nginx \
  yum clean all && \
    all='golang.go \
    mhutchie.git-graph \
    alphabotsec.vscode-eclipse-keybindings \
    vscodevim.vim' ; \
    for i in $all ; do code-server --install-extension $i ; done

# install nodejs
RUN wget https://nodejs.org/download/release/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz && \
  tar -xvf node-${NODEJS_VERSION}-linux-x64.tar.gz && \
  mv node-${NODEJS_VERSION}-linux-x64 /usr/local/nodejs && \
  echo 'export PATH=$PATH:/usr/local/nodejs/bin' >>  ${BASH_RC} && \
  rm -rf node-${NODEJS_VERSION}-linux-x64.tar.gz 

# install chrome
RUN yum install -y chromedriver && \
  yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm && \
  yum clean all

# # install glibc
# RUN wget https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${GLBC_VERSION}.tar.gz && \
#   tar -zxvf  ${GLBC_VERSION}.tar.gz && \
#   cd ${GLBC_VERSION} && \
#   mkdir build && \
#   cd build/ && \
#   ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin && \
#   make -j 8 && \
#   make install && \
#   cd ../.. && rm -rf ${GLBC_VERSION} ${GLBC_VERSION}.tar.gz

ADD ./hack ./hack
