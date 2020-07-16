FROM alpine:latest

RUN apk add --update bash git dnsmasq bind-tools curl jq && rm -rf /var/cache/apk/*

WORKDIR /app
COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/
COPY dnsmasq.conf /etc/

RUN case $(uname -m) in \
	armv7l)				\
		ARCH=arm		\
	;;					\
	arm64|aarch64)		\
		ARCH=arm64		\
	;;					\
	amd64|x86_64)		\
		ARCH=x86_64		\
	;;					\
	*)					\
		echo "Unhandled arch $(uname -m)!  Please report!" \
		ARCH=unknown	\
	;;					\
	esac;				\
	echo "Fetching dnscrypt-proxy-latest for ${ARCH}" && \
	VER=$(curl -sL https://api.github.com/repos/jedisct1/dnscrypt-proxy/releases/latest | jq -j .name) && \
	curl -s -L https://github.com/jedisct1/dnscrypt-proxy/releases/download/${VER}/dnscrypt-proxy-linux_${ARCH}-${VER}.tar.gz > dnscrypt-proxy-linux_${ARCH}.tar.gz && \
	tar -xzf dnscrypt-proxy-linux_${ARCH}.tar.gz && \
	mv linux-${ARCH}/dnscrypt-proxy /usr/bin/dnscrypt-proxy && \
	rm -rf dnscrypt-proxy-linux_${ARCH}.tar.gz linux-${ARCH}

RUN addgroup -g 1000 proxy && \
	adduser -u 1000 -G proxy -H proxy -S && \
	touch /etc/dnscrypt-proxy/dnscryptProxy.pid && \
	chown -R proxy:proxy /etc/dnscrypt-proxy

COPY docker-build-install.sh .
RUN bash docker-build-install.sh

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
