GLBC_VERSION ?= glibc-2.18

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
