#!/bin/bash

# Variables
EC2_USER="ec2-user"           # Replace with the correct user for your EC2 instance (e.g., ubuntu for Ubuntu instances)
EC2_HOST="52.91.103.56" # Replace with your EC2 instance's public IP address or DNS name
SSH_KEY_PATH="~/.ssh/rsa_key" # Replace with the path to your private key
REMOTE_DIR="/home/ec2-user/Task/flasktask" # Directory on EC2 where the app is located

# Ensure the SSH key has the correct permissions
chmod 600 $SSH_KEY_PATH

# Deploy the application
ssh -i $SSH_KEY_PATH -o StrictHostKeyChecking=no $EC2_USER@$EC2_HOST << EOF
  # Navigate to the project directory or exit if not found
  cd $REMOTE_DIR || { echo "Directory not found"; exit 1; }
  
  # Pull the latest changes from the main branch
  git pull origin main || { echo "Failed to pull from git"; exit 1; }
  
  # Build the Docker image
  docker build -t flasktask . || { echo "Docker build failed"; exit 1; }
  
  # Stop and remove any existing containers
  docker stop flasktask-container || true
  docker rm flasktask-container || true
  
  # Run the new container
  docker run -d -p 80:5000 --name flasktask-container flasktask || { echo "Docker run failed"; exit 1; }
EOF
