FROM haproxy:1.7.2-alpine
RUN apk add --no-cache \
       bash \
       rsyslog

ENV RSYSLOG=y

COPY docker-entrypoint.sh  /
COPY rsyslogd.conf         /etc/rsyslogd.conf

COPY certs/bundle.pem /etc/haproxy/bundle.pem
COPY certs/ca.pem /etc/haproxy/ca.pem
COPY haproxy.cfg /etc/haproxy/haproxy.cfg

WORKDIR "/etc/haproxy"
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["haproxy", "-f", "haproxy.cfg"]
