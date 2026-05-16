.PHONY: proto sqlc migrate migrate-status build run infra

DATABASE_URL ?= postgres://mlplatform:mlplatform@localhost:5432/mlplatform?sslmode=disable

# ----- Infrastructure -----
infra:
	docker compose up -d
infra-down:
	docker compose down

# ----- Code Generation -----
proto:
	buf dep update
	buf generate
sqlc:
	cd go-control-plane && sqlc generate

# ----- Database -----                                                             
migrate:                                                                         
	cd go-control-plane && goose -dir migrations postgres "$(DATABASE_URL)" up 
																				
migrate-status:                                                                  
	cd go-control-plane && goose -dir migrations postgres "$(DATABASE_URL)" sta
																				
migrate-down:                                         
	cd go-control-plane && goose -dir migrations postgres "$(DATABASE_URL)" dow

# ---- Build & Run -----                                                            
build:                                                
	cd go-control-plane && go build ./...                                      
											
run:                                                                             
	cd go-control-plane && go run ./cmd/experiment-manager/