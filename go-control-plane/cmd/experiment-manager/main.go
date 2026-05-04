package main

import (
	"log"
	"net"

	pb "github.com/tradaokamsa/ml-platform/go-control-plane/internal/grpc/training/v1"
	"google.golang.org/grpc"
	"google.golang.org/grpc/reflection"
)

type server struct {
	pb.UnimplementedExperimentManagerServiceServer
}

func main() {
	lis, err := net.Listen("tcp", ":9090")
	if err != nil {
		log.Fatalf("failed to listen: %v", err)
	}

	s := grpc.NewServer()
	pb.RegisterExperimentManagerServiceServer(s, &server{})
	reflection.Register(s)

	log.Println("experiment-manager listening on :9090")
	if err := s.Serve(lis); err != nil {
		log.Fatalf("failed to serve: %v", err)
	}
}