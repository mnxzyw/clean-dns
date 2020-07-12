FROM alpine:latest
RUN apk update && apk upgrade
RUN apk add bash git dnsmasq dnscrypt-proxy
RUN wget https://raw.githubusercontent.com/mnxzyw/dnsmasq-china-list/master/docker-build-install.sh && bash docker-build-install.sh

COPY dnscrypt-proxy.toml /etc/dnscrypt-proxy/
COPY dnsmasq.conf /etc/
COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
