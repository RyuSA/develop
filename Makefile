.PHONY: dnsmasq

dnsmasq: 
	docker build -t ryusa/dnsmasq:0.1 dnsmasq/
