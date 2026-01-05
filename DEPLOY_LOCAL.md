# Deploying from Local Machine

This guide is for deploying from your local terminal (Mac, Linux, or Windows).

## Prerequisites

### 1. Install Google Cloud SDK

**macOS:**
```bash
# Using Homebrew (recommended)
brew install --cask google-cloud-sdk

# Or download from: https://cloud.google.com/sdk/docs/install
```

**Linux:**
```bash
# Download and install from:
# https://cloud.google.com/sdk/docs/install
```

**Windows:**
- Download installer from: https://cloud.google.com/sdk/docs/install
- Run the installer and follow instructions

### 2. Install Docker

**macOS:**
```bash
# Using Homebrew
brew install --cask docker

# Or download Docker Desktop from: https://www.docker.com/products/docker-desktop
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker

# Add your user to docker group (to run without sudo)
sudo usermod -aG docker $USER
# Log out and back in for this to take effect
```

**Windows:**
- Download Docker Desktop from: https://www.docker.com/products/docker-desktop

### 3. Verify Installations

```bash
# Check gcloud
gcloud --version

# Check Docker
docker --version

# Authenticate with Google Cloud
gcloud auth login

# Initialize gcloud (if first time)
gcloud init

# Configure Docker for GCP
gcloud auth configure-docker
```

## Step 1: Set Up Your Project

```bash
# Navigate to your project
cd /Users/sriharshagorla/Desktop/pdf-chatbot-starter

# Set your project ID
export PROJECT_ID=your-project-id
export REGION=us-central1
export LLM_API_KEY=your-openai-api-key

# Set the project
gcloud config set project $PROJECT_ID

# Verify
gcloud config list
```

## Step 2: Enable APIs

```bash
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

## Step 3: Deploy

### Option A: Using the Deploy Script

```bash
# Make sure you're in the project root
cd /Users/sriharshagorla/Desktop/pdf-chatbot-starter

# Set environment variables
export GCP_PROJECT_ID=your-project-id
export GCP_REGION=us-central1
export LLM_API_KEY=your-openai-api-key

# Run deployment
chmod +x deploy.sh
./deploy.sh
```

### Option B: Manual Deployment

```bash
# Build and push backend
cd backend
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest

# Deploy backend
gcloud run deploy pdf-chatbot-backend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --memory 2Gi \
  --cpu 2 \
  --timeout 300 \
  --set-env-vars LLM_API_KEY=$LLM_API_KEY

# Get backend URL
BACKEND_URL=$(gcloud run services describe pdf-chatbot-backend --region $REGION --format 'value(status.url)')
echo "Backend URL: $BACKEND_URL"

# Build and push frontend
cd ../frontend
docker build --build-arg NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL -t gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest

# Deploy frontend
gcloud run deploy pdf-chatbot-frontend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --set-env-vars NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL

# Get frontend URL
FRONTEND_URL=$(gcloud run services describe pdf-chatbot-frontend --region $REGION --format 'value(status.url)')
echo "Frontend URL: $FRONTEND_URL"
```

## Advantages of Local Deployment

✅ Faster builds (uses your local machine power)  
✅ Full control over environment  
✅ Can test Docker images locally before pushing  
✅ Better for CI/CD integration  
✅ Easier to debug issues  
✅ Can use your preferred IDE/editor  

## Troubleshooting

### Docker daemon not running
```bash
# macOS: Start Docker Desktop app
# Linux: 
sudo systemctl start docker
# Windows: Start Docker Desktop app
```

### Permission denied (Docker)
```bash
# Linux: Add user to docker group
sudo usermod -aG docker $USER
# Log out and back in

# Or use sudo (not recommended)
sudo docker ...
```

### Authentication issues
```bash
# Re-authenticate
gcloud auth login
gcloud auth application-default login
gcloud auth configure-docker
```

### Network issues
- Check your firewall
- Ensure you can access gcr.io (Google Container Registry)
- Try using Cloud Build instead if Docker push fails

## Recommended: Hybrid Approach

1. **Develop locally** - Use your local machine for development
2. **Deploy from Cloud Shell** - Use Cloud Shell for deployment (easier)
3. **Or use CI/CD** - Set up Cloud Build for automated deployments



