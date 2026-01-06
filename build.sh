#!/bin/bash
set -e

echo "Building single Spring Boot application..."

# Step 1: Build Next.js frontend
echo "Step 1: Building Next.js frontend..."
cd frontend
npm install
npm run build

# Step 2: Copy Next.js output to Spring Boot static resources
echo "Step 2: Copying frontend build to Spring Boot resources..."
mkdir -p ../backend/src/main/resources/static

# Copy the Next.js export (if using static export) or build output
if [ -d ".next" ]; then
    # For Next.js standalone build, copy the necessary files
    if [ -d ".next/standalone" ]; then
        # Copy static files
        cp -r .next/static ../backend/src/main/resources/static/_next/static 2>/dev/null || true
        # For static export, we need to export first
        echo "Note: Next.js standalone mode detected. Updating build process..."
    fi
fi

# Export Next.js as static HTML (better for Spring Boot)
echo "Exporting Next.js as static HTML..."
# Update next.config.js for static export if needed
npm run build

# Copy exported files
if [ -d "out" ]; then
    cp -r out/* ../backend/src/main/resources/static/
elif [ -d ".next" ]; then
    # Fallback: copy what we can
    echo "Warning: Using .next directory. Some features may not work."
    # We'll handle this in the Dockerfile
fi

cd ..

# Step 3: Build Spring Boot application
echo "Step 3: Building Spring Boot application..."
cd backend
mvn clean package -DskipTests

echo "Build complete! JAR file: target/pdf-chatbot-0.0.1.jar"


