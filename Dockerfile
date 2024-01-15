FROM centos:7

ENV BASH_RC=/etc/bashrc

WORKDIR /home/workspace

### install_base_tools
ENV LANG=zh_CN.utf8
RUN yum update -y && \
  yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y && \
  yum install -y epel-release && \
  yum install -y \
    curl net-tools wget bash-completion jq unzip fontconfig gettext expect \
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
ENV GIT_USER=nfyxhan
ENV GIT_EMAIL=nfyxhan@163.com
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
ENV GH_VERSION=2.34.0
RUN curl -L https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_amd64.tar.gz | \
  tar -zx -C /usr/local/ && \
  echo 'export PATH=$PATH:/usr/local/'gh_${GH_VERSION}_linux_amd64'/bin' >>  ${BASH_RC} 

### install_kubectl_helm
ENV KUBE_VERSION=v1.24.15
ENV KUBEBUILDER_VERSION=v3.12.0
ENV HELM_VERSION=v3.6.3
RUN curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  echo 'source <(kubectl completion bash)' >>  ${BASH_RC} && \
  curl -Lo /usr/bin/kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/${KUBEBUILDER_VERSION}/kubebuilder_linux_amd64 && \
  chmod +x /usr/bin/kubebuilder && \
  echo 'source <(kubebuilder completion bash)' >>  ${BASH_RC} && \
  mkdir -p /usr/local/helm && \
  curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz | \
  tar -zx -C /usr/local/helm/ --strip-components 1 && \
  echo 'export PATH=$PATH:/usr/local/helm/' >> ${BASH_RC} && \
  echo 'source <(helm completion bash)' >>  ${BASH_RC}

### install_nodejs
ENV NODEJS_VERSION=v14.21.3
RUN curl -L https://nodejs.org/download/release/${NODEJS_VERSION}/node-${NODEJS_VERSION}-linux-x64.tar.gz | \
  tar -zx -C /usr/local/ && \
  echo 'export PATH=$PATH:/usr/local/'node-${NODEJS_VERSION}-linux-x64'/bin' >>  ${BASH_RC}

### install_go
ENV GO_VERSION=1.17.10
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn
RUN curl -L https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz | \
    tar -zx -C /usr/local/ && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ${BASH_RC} && \
    echo 'export PATH=$PATH:${GOPATH}/bin' >>  ${BASH_RC}

### install_code_server
RUN rpm -i https://github.com/coder/code-server/releases/download/v4.16.1/code-server-4.16.1-amd64.rpm && \
    all='golang.go \
    mhutchie.git-graph \
    waderyan.gitblame \
    alphabotsec.vscode-eclipse-keybindings \
    vscodevim.vim \
    donjayamanne.githistory \
    richie5um2.vscode-sort-json \
    raer0.codium-insertdatestring \
    Vue.volar' ; \
    for i in $all ; do code-server --install-extension $i ; done

ADD ./hack ./hack

ADD ./Dockerfile .

ADD ./Makefile .
