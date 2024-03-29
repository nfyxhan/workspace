GLBC_VERSION ?= glibc-2.18

chrome:
	yum install -y chromedriver
	yum install -y https://dl.google.com/linux/direct/google-chrome-stable_current_x86_64.rpm
	yum clean all

drawio:
	code-server --install-extension hediet.vscode-drawio

all='golang.org/x/tools/cmd/goimports@v0.11.1 \
    golang.org/x/tools/gopls@v0.11.0 \
    github.com/go-delve/delve/cmd/dlv@v1.9.1 \
    github.com/swaggo/swag/cmd/swag@v1.8.9 \
    github.com/golang/mock/mockgen@v1.6.0 \
    golang.org/x/tools/cmd/stringer@v0.3.0 \
    github.com/golangci/golangci-lint/cmd/golangci-lint@v1.44.2 \
    github.com/cweill/gotests/gotests@v1.6.0 \
    github.com/fatih/gomodifytags@v1.16.0 \
    github.com/josharian/impl@v1.1.0 \
    github.com/PaulXu-cn/go-mod-graph-chart/gmchart@v0.5.3 \
    honnef.co/go/tools/cmd/staticcheck@v0.3.3'

go:
GOBIN=$(shell which go)

dev-tools:
    yum groupinstall "Development Tools" -y
    yum install -y centos-release-scl
    yum install devtoolset-9-libstdc++-devel -y 

go-tools:
	for i in $(shell echo ${all}) ; do echo installing $$i ; $(GOBIN) install $$i ; done 
