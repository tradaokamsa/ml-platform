.PHONY: proto build run

proto:
	buf dep update
	buf generate

build:
	cd go-control-plane && go build ./...

run:
	cd go-control-plane && go run ./cmd/experiment-manager/