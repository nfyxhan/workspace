GLBC_VERSION ?= glibc-2.18

chrome:
	yum install -y chromedriver
	yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	yum clean all

drawio:
	code-server --install-extension hediet.vscode-drawio

glibc:
	curl -L https://mirrors.tuna.tsinghua.edu.cn/gnu/glibc/${GLBC_VERSION}.tar.gz | \
	tar -zx && \
	cd ${GLBC_VERSION} && \
	mkdir build && \
	cd build/ && \
	../configure --prefix=/usr --disable-profile --enable-add-ons --with-headers=/usr/include --with-binutils=/usr/bin && \
	make -j 8 && \
	make install && \
	cd ../.. && rm -rf ${GLBC_VERSION}

all='golang.org/x/tools/cmd/goimports@v0.11.1 \
    golang.org/x/tools/gopls@v0.11.0 \
    github.com/go-delve/delve/cmd/dlv@v1.9.1 \
    github.com/swaggo/swag/cmd/swag@v1.8.9 \
    github.com/golang/mock/mockgen@v1.6.0 \
    golang.org/x/tools/cmd/stringer@v0.3.0 \
    github.com/golangci/golangci-lint/cmd/golangci-lint@v1.50.1 \
    github.com/cweill/gotests/gotests@v1.6.0 \
    github.com/fatih/gomodifytags@v1.16.0 \
    github.com/josharian/impl@v1.1.0 \
    github.com/PaulXu-cn/go-mod-graph-chart/gmchart@v0.5.3 \
    honnef.co/go/tools/cmd/staticcheck@v0.3.3'

go:
GOBIN=$(shell which go)

go-tools:
	for i in $(shell echo ${all}) ; do echo installing $$i ; $(GOBIN) install $$i ; done 
