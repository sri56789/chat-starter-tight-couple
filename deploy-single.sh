#!/bin/bash
set -e

# Configuration
PROJECT_ID=${GCP_PROJECT_ID:-"your-project-id"}
REGION=${GCP_REGION:-"us-central1"}
LLM_API_KEY=${LLM_API_KEY:-""}

if [ "$PROJECT_ID" = "your-project-id" ]; then
  echo "Error: Please set GCP_PROJECT_ID environment variable or edit deploy-single.sh"
  exit 1
fi

echo "Deploying single Spring Boot application to project: $PROJECT_ID"
echo "Region: $REGION"

# Set project
gcloud config set project $PROJECT_ID

# Enable APIs
echo "Enabling required APIs..."
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com

# Build and push Docker image
echo "Building Docker image..."
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot:latest .

echo "Pushing Docker image..."
docker push gcr.io/$PROJECT_ID/pdf-chatbot:latest

# Deploy to Cloud Run
echo "Deploying to Cloud Run..."
if [ -z "$LLM_API_KEY" ]; then
  gcloud run deploy pdf-chatbot \
    --image gcr.io/$PROJECT_ID/pdf-chatbot:latest \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 2 \
    --timeout 300 \
    --max-instances 10
else
  gcloud run deploy pdf-chatbot \
    --image gcr.io/$PROJECT_ID/pdf-chatbot:latest \
    --region $REGION \
    --platform managed \
    --allow-unauthenticated \
    --memory 2Gi \
    --cpu 2 \
    --timeout 300 \
    --max-instances 10 \
    --set-env-vars LLM_API_KEY=$LLM_API_KEY
fi

APP_URL=$(gcloud run services describe pdf-chatbot --region $REGION --format 'value(status.url)')

echo ""
echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "Application URL: $APP_URL"
echo ""
echo "Your single Spring Boot app is now live!"
echo "It serves both the UI and API from one endpoint."
echo "=========================================="


