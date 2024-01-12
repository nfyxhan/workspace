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