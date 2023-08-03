FROM centos:7

ENV GIT_USER=nfyxhan
ENV GIT_EMAIL=nfyxhan@163.com

ENV GO_VERSION=1.18.10
ENV GO111MODULE=on
ENV GOPROXY=https://goproxy.cn

ENV KUBE_VERSION=v1.24.15

WORKDIR /home/workspace

RUN yum update -y && \
  yum install https://packages.endpointdev.com/rhel/7/os/x86_64/endpoint-repo.x86_64.rpm -y && \
  yum install -y \
    curl net-tools git wget bash-completion \
    make gcc \
    ncurses-devel ruby ruby-devel lua lua-devel perl perl-devel python3 python3-devel python2-devel perl-ExtUtils-Embed lrzsz cmake gcc-c++ unzi && \
  yum clean all

RUN git config --global user.name "${GIT_USER}" && \
  git config --global user.email "${GIT_EMAIL}" && \
  ssh-keygen -f ~/.ssh/id_rsa -N ''

RUN git clone https://github.com/vim/vim && \
  cd vim && \
  ./configure --with-features=huge \
            --enable-rubyinterp=yes \
            --enable-luainterp=yes \
            --enable-perlinterp=yes \
            --enable-python3interp=yes \
            --enable-pythoninterp=yes \
            --with-python-config-dir=/usr/lib64/python2.7/config \
            --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu \
            --enable-fontset=yes \
            --enable-cscope=yes \
            --enable-multibyte \
            --disable-gui \
            --enable-fail-if-missing \
            --prefix=/usr/local \
            --with-compiledby='Professional operations' && \
  make VIMRUNTIMEDIR=/usr/local/share/vim/vim82 && make install && \
  cd .. && rm -rf vim
  
RUN  rm -rf ~/.vim && \
  git clone https://github.com/nfyxhan/vim.git && \
  mv vim ~/.vim && \
  vim +PlugClean[!] +PlugUpdate +qa && \
  echo "alias vi='vim '" >>  ~/.bashrc

RUN wget https://golang.google.cn/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && \
    tar -C /usr/local -xzf go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -f go${GO_VERSION}.linux-amd64.tar.gz && \
    echo 'export PATH=$PATH:/usr/local/go/bin:${HOME}/go/bin' >>  ~/.bashrc
RUN go install golang.org/x/tools/cmd/goimports@v0.11.1

RUN curl -Lo ./kubectl https://dl.k8s.io/release/${KUBE_VERSION}/bin/linux/amd64/kubectl && \
  chmod +x kubectl && \
  mv ./kubectl /usr/local/bin/ && \
  echo 'source <(kubectl completion bash)' >>  ~/.bashrc
