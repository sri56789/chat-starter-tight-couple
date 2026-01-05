# Google Cloud Deployment Guide

This guide will help you deploy the PDF Chatbot application to Google Cloud Platform.

## 🚀 Choose Your Deployment Method

**Option 1: Google Cloud Shell (Recommended for Beginners)**  
→ See [DEPLOY_CLOUD_SHELL.md](./DEPLOY_CLOUD_SHELL.md)  
✅ No local setup needed  
✅ Works from any computer  
✅ Pre-configured tools  

**Option 2: Local Machine**  
→ See [DEPLOY_LOCAL.md](./DEPLOY_LOCAL.md)  
✅ Faster builds  
✅ More control  
✅ Better for CI/CD  

**Option 3: Automated CI/CD**  
→ Use Cloud Build with `cloudbuild.yaml`  
✅ Automated deployments  
✅ Git-based workflow  

---

## Quick Comparison

| Feature | Cloud Shell | Local Machine |
|---------|-------------|---------------|
| Setup Required | None | Docker + gcloud SDK |
| Speed | Medium | Fast |
| Internet Required | Yes | Yes |
| Can Test Locally | No | Yes |
| Best For | Quick deploy, learning | Production, CI/CD |

## Prerequisites

1. **Google Cloud Account**: Sign up at https://cloud.google.com
2. **Google Cloud SDK**: Install from https://cloud.google.com/sdk/docs/install
3. **Docker**: Ensure Docker is installed locally (optional, for local testing)
4. **Billing Enabled**: Enable billing on your GCP project

## Initial Setup

### 1. Create a Google Cloud Project

```bash
# Set your project ID (replace with your desired project ID)
export PROJECT_ID=your-project-id
export REGION=us-central1

# Create the project
gcloud projects create $PROJECT_ID

# Set as current project
gcloud config set project $PROJECT_ID

# Enable billing (link your billing account)
gcloud billing projects link $PROJECT_ID --billing-account=YOUR_BILLING_ACCOUNT_ID
```

### 2. Enable Required APIs

```bash
# Enable Cloud Run API
gcloud services enable run.googleapis.com

# Enable Container Registry API
gcloud services enable containerregistry.googleapis.com

# Enable Cloud Build API
gcloud services enable cloudbuild.googleapis.com

# Enable Artifact Registry API (newer, preferred)
gcloud services enable artifactregistry.googleapis.com
```

### 3. Configure Authentication

```bash
# Authenticate with Google Cloud
gcloud auth login

# Configure Docker to use gcloud as credential helper
gcloud auth configure-docker
```

## Deployment Options

### Option 1: Deploy to Cloud Run (Recommended)

Cloud Run is serverless and automatically scales based on traffic.

#### Step 1: Build and Push Docker Images

**Backend:**
```bash
cd backend

# Build the Docker image
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest .

# Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest
```

**Frontend:**
```bash
cd frontend

# Build with backend URL
docker build \
  --build-arg NEXT_PUBLIC_BACKEND_URL=https://pdf-chatbot-backend-${REGION}-${PROJECT_ID}.a.run.app \
  -t gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest .

# Push to Google Container Registry
docker push gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest
```

#### Step 2: Deploy Backend to Cloud Run

```bash
gcloud run deploy pdf-chatbot-backend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 300 \
  --max-instances 10 \
  --set-env-vars LLM_API_KEY=your-openai-api-key-here
```

**Note**: Replace `your-openai-api-key-here` with your actual OpenAI API key.

#### Step 3: Deploy Frontend to Cloud Run

First, get your backend URL:
```bash
BACKEND_URL=$(gcloud run services describe pdf-chatbot-backend --region $REGION --format 'value(status.url)')
echo "Backend URL: $BACKEND_URL"
```

Then deploy frontend:
```bash
gcloud run deploy pdf-chatbot-frontend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --timeout 60 \
  --max-instances 10 \
  --set-env-vars NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL
```

#### Step 4: Get Your Application URLs

```bash
# Get backend URL
gcloud run services describe pdf-chatbot-backend --region $REGION --format 'value(status.url)'

# Get frontend URL
gcloud run services describe pdf-chatbot-frontend --region $REGION --format 'value(status.url)'
```

### Option 2: Deploy Using Cloud Build (Automated)

For automated CI/CD:

1. **Create a Cloud Build trigger** (via Console):
   - Go to Cloud Build > Triggers
   - Connect your repository (GitHub, Bitbucket, etc.)
   - Use `cloudbuild.yaml` as the configuration file

2. **Or deploy manually using Cloud Build**:
   ```bash
   gcloud builds submit --config cloudbuild.yaml
   ```

**Note**: Before running, update the `NEXT_PUBLIC_BACKEND_URL` in `cloudbuild.yaml` with your actual backend URL, or use Cloud Build substitutions.

### Option 3: Deploy Backend to App Engine (Alternative)

If you prefer App Engine over Cloud Run:

```bash
cd backend
gcloud app deploy app.yaml
```

## Setting Environment Variables

### For Cloud Run (Backend)

Set the OpenAI API key:
```bash
gcloud run services update pdf-chatbot-backend \
  --region $REGION \
  --update-env-vars LLM_API_KEY=your-openai-api-key-here
```

### Using Secret Manager (Recommended for Production)

1. Create a secret:
   ```bash
   echo -n "your-openai-api-key" | gcloud secrets create llm-api-key --data-file=-
   ```

2. Grant Cloud Run access:
   ```bash
   gcloud secrets add-iam-policy-binding llm-api-key \
     --member="serviceAccount:PROJECT_NUMBER-compute@developer.gserviceaccount.com" \
     --role="roles/secretmanager.secretAccessor"
   ```

3. Update the Cloud Run service to use the secret:
   ```bash
   gcloud run services update pdf-chatbot-backend \
     --region $REGION \
     --update-secrets LLM_API_KEY=llm-api-key:latest
   ```

## Storage for PDFs

### Option 1: Cloud Storage Bucket (Recommended)

1. Create a bucket:
   ```bash
   gsutil mb -l $REGION gs://$PROJECT_ID-pdfs
   ```

2. Update `PdfService.java` to read from Cloud Storage instead of local filesystem.

### Option 2: Cloud Filestore

For persistent file storage, use Cloud Filestore and mount it as a volume in Cloud Run.

## Monitoring and Logging

View logs:
```bash
# Backend logs
gcloud run services logs read pdf-chatbot-backend --region $REGION

# Frontend logs
gcloud run services logs read pdf-chatbot-frontend --region $REGION
```

## Cost Estimation

- **Cloud Run**: Pay per request + compute time
  - Backend: ~$0.40 per million requests + compute
  - Frontend: ~$0.40 per million requests + compute
  - Free tier: 2 million requests/month

- **Container Registry**: Free for first 5GB storage

- **Typical small usage**: $5-20/month

## Troubleshooting

### Backend not starting
- Check logs: `gcloud run services logs read pdf-chatbot-backend --region $REGION`
- Verify memory settings (2Gi minimum)
- Check environment variables

### Frontend can't connect to backend
- Verify `NEXT_PUBLIC_BACKEND_URL` is set correctly
- Check CORS settings in backend
- Ensure backend allows unauthenticated requests

### PDF processing errors
- Increase memory allocation for backend
- Check Cloud Storage bucket permissions (if using)

## Updating the Application

To update after code changes:

```bash
# Rebuild and redeploy backend
cd backend
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest
gcloud run deploy pdf-chatbot-backend --image gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest --region $REGION

# Rebuild and redeploy frontend
cd ../frontend
docker build --build-arg NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL -t gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest
gcloud run deploy pdf-chatbot-frontend --image gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest --region $REGION
```

## Cleanup

To delete all resources:

```bash
# Delete Cloud Run services
gcloud run services delete pdf-chatbot-backend --region $REGION
gcloud run services delete pdf-chatbot-frontend --region $REGION

# Delete images
gcloud container images delete gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest
gcloud container images delete gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest

# Delete project (careful!)
gcloud projects delete $PROJECT_ID
```

## Quick Start Script

Create a `deploy.sh` script:

```bash
#!/bin/bash
set -e

PROJECT_ID=your-project-id
REGION=us-central1
LLM_API_KEY=your-api-key

# Set project
gcloud config set project $PROJECT_ID

# Build and deploy backend
cd backend
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest
gcloud run deploy pdf-chatbot-backend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest \
  --region $REGION \
  --allow-unauthenticated \
  --memory 2Gi \
  --set-env-vars LLM_API_KEY=$LLM_API_KEY

BACKEND_URL=$(gcloud run services describe pdf-chatbot-backend --region $REGION --format 'value(status.url)')

# Build and deploy frontend
cd ../frontend
docker build --build-arg NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL -t gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest
gcloud run deploy pdf-chatbot-frontend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest \
  --region $REGION \
  --allow-unauthenticated \
  --set-env-vars NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL

echo "Deployment complete!"
echo "Frontend URL: $(gcloud run services describe pdf-chatbot-frontend --region $REGION --format 'value(status.url)')"
```

Make it executable:
```bash
chmod +x deploy.sh
```

