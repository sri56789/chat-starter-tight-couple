#!/bin/bash
set -e

echo "Building application for local development..."

# Step 1: Build Next.js frontend
echo "Step 1: Building Next.js frontend..."
cd frontend

# Check if node_modules exists, if not install
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

# Build the frontend
echo "Building Next.js..."
npm run build

# Step 2: Copy Next.js output to Spring Boot static resources
echo "Step 2: Copying frontend build to Spring Boot resources..."
cd ..

# Create static directory
mkdir -p backend/src/main/resources/static

# Copy the exported files
if [ -d "frontend/out" ]; then
    echo "Copying from frontend/out..."
    cp -r frontend/out/* backend/src/main/resources/static/
    echo "✓ Frontend files copied successfully"
else
    echo "ERROR: frontend/out directory not found!"
    echo "Make sure Next.js build completed successfully."
    exit 1
fi

# Step 3: Build Spring Boot application
echo ""
echo "Step 3: Building Spring Boot application..."
cd backend
mvn clean package -DskipTests

echo ""
echo "=========================================="
echo "Build complete!"
echo "=========================================="
echo "JAR file: backend/target/pdf-chatbot-0.0.1.jar"
echo ""
echo "Run with: java -jar backend/target/pdf-chatbot-0.0.1.jar"
echo "Then open: http://localhost:8080"
echo "=========================================="


