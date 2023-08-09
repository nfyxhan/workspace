FROM centos:7

ENV GIT_USER=nfyxhan
ENV GIT_EMAIL=nfyxhan@163.com

ENV GO_VERSION=1.18.10
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.io

ENV GLBC_VERSION=glibc-2.18

ENV KUBE_VERSION=v1.24.15

WORKDIR /home/workspace

# install base tools
RUN yum update -y && \
  yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y && \
  yum install -y \
    curl vim net-tools git wget bash-completion \
    make gcc \
    && \
  wget -O /etc/yum.repos.d/lbiaggi-vim80-ligatures-epel-7.repo https://copr.fedorainfracloud.org/coprs/lbiaggi/vim80-ligatures/repo/epel-7/lbiaggi-vim80-ligatures-epel-7.repo && \
  yum update -y && \
  yum clean all

# config git
RUN git config --global user.name "${GIT_USER}" && \
  git config --global user.email "${GIT_EMAIL}" && \
  ssh-keygen -f ~/.ssh/id_rsa -N ''

# config vim 
RUN  rm -rf ~/.vim && \
  git clone https://github.com/nfyxhan/vim.git && \
  mv vim ~/.vim && \
  vim +PlugClean[!] +PlugUpdate +qa && \
  echo "alias vi='vim '" >>  ~/.bashrc

# install go
RUN wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -f go${GO_VERSION}.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin:${HOME}/go/bin' >>  ~/.bashrc && \
    source ~/.bashrc && \
    go install golang.org/x/tools/cmd/goimports@v0.11.1 && \
    go install golang.org/x/tools/gopls@v0.11.0 && \
    go install github.com/go-delve/delve/cmd/dlv@v1.21.0 && \
    go install github.com/swaggo/swag/cmd/swag@v1.8.9 && \
    go install github.com/golang/mock/mockgen@v1.6.0 && \
    go install golang.org/x/tools/cmd/stringer@v0.3.0 && \
    go install github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1

# install kubectl
RUN curl -Lo ./kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv ./kubectl /usr/local/bin/ && \
  echo 'source <(kubectl completion bash)' >>  ~/.bashrc

# install code-server
RUN rpm -i https://github.com/coder/code-server/releases/download/v4.16.1/code-server-4.16.1-amd64.rpm

# install glibc
RUN wget https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${GLBC_VERSION}.tar.gz && \
  tar -zxvf  ${GLBC_VERSION}.tar.gz && \
  cd ${GLBC_VERSION} && \
  mkdir build && \
  cd build/ && \
  ../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin && \
  make -j 8 && \
  make install && \
  cd ../.. && rm -rf ${GLBC_VERSION} ${GLBC_VERSION}.tar.gz
