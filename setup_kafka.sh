#!/bin/bash

echo "Setting up Kafka topics..."

# Wait for Kafka to be ready
sleep 15

# Create topics
docker-compose exec kafka kafka-topics --create --topic driver_status --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1
docker-compose exec kafka kafka-topics --create --topic order_request --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1
docker-compose exec kafka kafka-topics --create --topic order_response --bootstrap-server kafka:9092 --partitions 1 --replication-factor 1

echo "Kafka topics created successfully!"