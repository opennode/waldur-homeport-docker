build:
	docker build -t docker.io/opennode/waldur-homeport .

build-nocache:
	docker build --no-cache -t docker.io/opennode/waldur-homeport .

push:
	docker push docker.io/opennode/waldur-homeport

