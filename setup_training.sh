#!/bin/bash

echo "Setting up training data..."

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
sleep 10

# Create sample training data
echo "Creating sample training data..."
docker-compose exec backend python create_sample_training.py

echo "Training data setup completed!"