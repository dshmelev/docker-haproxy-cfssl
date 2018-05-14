all: gen_cert build test

gen_cert:
	bin/gen_cert
build:
	docker build -t twiket-haproxy .
test:
	docker run -it --rm --name haproxy-syntax-check twiket-haproxy -f /etc/haproxy/haproxy.cfg -c
