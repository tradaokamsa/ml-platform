package main

import (
	"context"
	"log"
	"net"
	"os"

	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"

	"github.com/jackc/pgx/v5/pgxpool"
	db "github.com/tradaokamsa/ml-platform/go-control-plane/internal/db"
	pb "github.com/tradaokamsa/ml-platform/go-control-plane/internal/grpc/training/v1"
)

type server struct {
	pb.UnimplementedExperimentManagerServiceServer
	queries *db.Queries
}

func main() {
	databaseURL := os.Getenv("DATABASE_URL")
	if databaseURL == "" {
		databaseURL = "postgres://mlplatform:mlplatform@localhost:5432/mlplatform?sslmode=disable"
	}

	pool, err := pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		log.Fatalf("failed to connect to database: %v", err)
	}
	defer pool.Close()

	if err := pool.Ping(context.Background()); err != nil {
		log.Fatalf("failed to ping database: %v", err)
	}
	log.Println("connected to database")

	queries := db.New(pool)

	lis, err := net.Listen("tcp", ":9090")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterExperimentManagerServiceServer(s, &server{queries: queries})
	reflection.Register(s)

	log.Println("experiment-manager listening on :9090")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}