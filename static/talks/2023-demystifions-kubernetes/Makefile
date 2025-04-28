all: marp build push

marp:
	docker run --rm -v ${PWD}:/home/marp/app/ -e LANG=${LANG} -e MARP_USER="$(id -u):$(id -g)" marpteam/marp-cli index.md

build:
	docker buildx create --use
	docker buildx build --platform=linux/amd64,linux/arm64 -t zwindler/dk .

push:
	docker buildx build --platform=linux/amd64,linux/arm64 --push -t zwindler/dk .
