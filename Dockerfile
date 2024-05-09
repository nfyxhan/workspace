FROM redhat/ubi8:8.9-1136
# FROM centos:7

# ARG TARGETPLATFORM=linux/amd64

ENV BASH_RC=/etc/bashrc

WORKDIR /home/workspace
env WORKDIR /home/workspace 

add ./hack/env.sh ./env.sh

### install_base_tools
ENV LANG=zh_CN.utf8
RUN . ./env.sh && \
  yum update -y && \
  yum install -y http://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm && \
  yum install -y \
    curl net-tools wget bash-completion jq unzip fontconfig gettext \
    make gcc gcc-c++ \
    git openssh-server \
    vim diffutils \
    graphviz \
    expect \
    nginx \
    procps \
    && \
  yum clean all

RUN yum install -y glibc-locale-source glibc-langpack-en && \
  yum clean all && \
  ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  echo "Asia/Shanghai" > /etc/timezone && \
  mkdir -p /usr/share/fonts/chinese/ && \
  wget -O /usr/share/fonts/chinese/SourceHanSansSC-Light.otf \
    https://raw.githubusercontent.com/adobe-fonts/source-han-sans/release/OTF/SimplifiedChinese/SourceHanSansSC-Light.otf && \
  fc-cache -fv && \
  localedef -c -f UTF-8 -i zh_CN zh_CN.utf-8 && \
  locale

# env TCL_VERSION=8.6.14
# env EXPECT_VERSION=5.45.4
# RUN . ./env.sh && \
#   curl -L https://jaist.dl.sourceforge.net/project/tcl/Tcl/${TCL_VERSION}/tcl${TCL_VERSION}-src.tar.gz | \
#   tar -zx && \
#   cd tcl${TCL_VERSION}/unix/ && \
#   ./configure --prefix=/usr/tcl --enable-shared && \
#   make && \
#   make install && \
#   cp tclUnixPort.h ../generic && \
#   cd ../.. && \
#     curl -L https://jaist.dl.sourceforge.net/project/expect/Expect/${EXPECT_VERSION}/expect${EXPECT_VERSION}.tar.gz | \
#   tar -zx && \
#   cd expect${EXPECT_VERSION} && \
#   ./configure --build=$(echo -n ${RUN_PLATFORM}| sed s'/arm64/arm/'g | sed s'/amd64/x86-64/'g)-linux --prefix=/usr/expect --with-tcl=/usr/tcl/lib --with-tclinclude=${WORKDIR}/tcl${TCL_VERSION}/generic && \
#   make && \
#   make install && \
#   ln -s /usr/tcl/bin/expect /usr/bin/expect && \
#   cd .. && rm -rf expect* tcl*


# expect kernel-devel 
# stress-ng \
# yum install https://packages.endpointdev.com/rhel/7/os/SRPMS/endpoint-repo-1.10-1.src.rpm -y && \
# yum install -y git
#  wget -O /etc/yum.repos.d/lbiaggi-vim80-ligatures-epel-7.repo \
#   https://copr.fedorainfracloud.org/coprs/lbiaggi/vim80-ligatures/repo/epel-7/lbiaggi-vim80-ligatures-epel-7.repo && \
  # yum update -y && \

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
RUN pwd && ls -la && \
  . ./env.sh && \ 
  curl -L https://github.com/cli/cli/releases/download/v${GH_VERSION}/gh_${GH_VERSION}_linux_${RUN_PLATFORM}.tar.gz | \
  tar -zx -C /usr/local/ && \
  echo 'export PATH=$PATH:/usr/local/'gh_${GH_VERSION}_linux_${RUN_PLATFORM}'/bin' >> ${BASH_RC} && \
  echo 'source <(gh completion bash)' >> ${BASH_RC}

### install_go
ENV GO_VERSION=1.18.10
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn
RUN . ./env.sh && \ 
    curl -L https://golang.google.cn/dl/go${GO_VERSION}.linux-${RUN_PLATFORM}.tar.gz | \
    tar -zx -C /usr/local/ && \
    echo 'export PATH=$PATH:/usr/local/go/bin' >> ${BASH_RC} && \
    echo 'export PATH=$PATH:${GOPATH}/bin' >>  ${BASH_RC}

### install_kubectl_helm
ENV KUBE_VERSION=v1.26.11
ENV KUBEBUILDER_VERSION=v3.12.0
ENV HELM_VERSION=v3.6.3
RUN . ./env.sh && \ 
  curl -Lo /usr/local/bin/kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/${RUN_PLATFORM}/kubectl && \
  chmod +x /usr/local/bin/kubectl && \
  echo 'source <(kubectl completion bash)' >>  ${BASH_RC} && \
  curl -Lo /usr/bin/kubebuilder https://github.com/kubernetes-sigs/kubebuilder/releases/download/${KUBEBUILDER_VERSION}/kubebuilder_linux_${RUN_PLATFORM} && \
  chmod +x /usr/bin/kubebuilder && \
  echo 'source <(kubebuilder completion bash)' >>  ${BASH_RC} && \
  mkdir -p /usr/local/helm && \
  curl -L https://get.helm.sh/helm-${HELM_VERSION}-linux-${RUN_PLATFORM}.tar.gz | \
  tar -zx -C /usr/local/helm/ --strip-components 1 && \
  echo 'export PATH=$PATH:/usr/local/helm/' >> ${BASH_RC} && \
  echo 'source <(helm completion bash)' >>  ${BASH_RC}

### install node version mamanger
ENV NVM_VERSION=0.33.1
ENV NODEJS_VERSION=v14.21.3
RUN wget -qO- https://raw.githubusercontent.com/creationix/nvm/v${NVM_VERSION}/install.sh | bash && \
  . ${HOME}/.bashrc && \
  nvm install ${NODEJS_VERSION}

### install_code_server
ENV CODE_SERVER_VERSION=4.20.1
RUN . ./env.sh && \
    rpm -iv https://github.com/coder/code-server/releases/download/v${CODE_SERVER_VERSION}/code-server-${CODE_SERVER_VERSION}-${RUN_PLATFORM}.rpm

ADD ./hack/replace-code-server-market.sh ./hack/
RUN sh ./hack/replace-code-server-market.sh && \
    all='golang.go \
    mhutchie.git-graph \
    waderyan.gitblame \
    alphabotsec.vscode-eclipse-keybindings \
    vscodevim.vim \
    donjayamanne.githistory \
    richie5um2.vscode-sort-json \
    jsynowiec.vscode-insertdatestring \
    SenseTime.raccoon \
    balazs4.gitlab-pipeline-monitor \
    EditorConfig.EditorConfig \
    wmaurer.change-case \
    oderwat.indent-rainbow \
    vscode-icons-team.vscode-icons \
    TaipaXu.github-trending \
    Vue.volar' ; \
    for i in $all ; do code-server --install-extension $i ; done

ADD ./hack/* ./hack/

ADD ./Dockerfile .

ADD ./Makefile .
