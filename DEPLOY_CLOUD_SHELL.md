# Deploying from Google Cloud Shell

This guide walks you through deploying from Google Cloud Shell (browser-based terminal).

## Step 1: Open Cloud Shell

1. Go to https://console.cloud.google.com
2. Click the **Cloud Shell** icon (terminal icon) in the top-right toolbar
3. Wait for Cloud Shell to open (it may take 30-60 seconds)

## Step 2: Upload Your Project

### Option A: Using Cloud Shell Editor (Easiest)

1. Click the **Open Editor** button (pencil icon) in Cloud Shell
2. In the editor, click **File > Upload** 
3. Upload your entire `pdf-chatbot-starter` folder as a ZIP file:
   - On your local machine, create a ZIP of the project folder
   - Upload the ZIP file
   - Extract it in Cloud Shell:
     ```bash
     unzip pdf-chatbot-starter.zip
     cd pdf-chatbot-starter
     ```

### Option B: Using Git (Recommended if you have code in Git)

1. If your code is in GitHub/GitLab:
   ```bash
   git clone https://github.com/your-username/pdf-chatbot-starter.git
   cd pdf-chatbot-starter
   ```

### Option C: Using gcloud upload

1. On your local machine, create a ZIP:
   ```bash
   cd /Users/sriharshagorla/Desktop
   zip -r pdf-chatbot-starter.zip pdf-chatbot-starter
   ```

2. In Cloud Shell, use `gcloud` to upload:
   ```bash
   # This is more complex, Option A is easier
   ```

## Step 3: Set Your Project ID

```bash
# Replace with your actual project ID
export PROJECT_ID=your-project-id
export REGION=us-central1

# Set the project
gcloud config set project $PROJECT_ID
```

## Step 4: Enable Required APIs

```bash
gcloud services enable run.googleapis.com
gcloud services enable containerregistry.googleapis.com
gcloud services enable cloudbuild.googleapis.com
```

## Step 5: Configure Authentication for Docker

```bash
gcloud auth configure-docker
```

## Step 6: Set Your OpenAI API Key (Optional)

```bash
export LLM_API_KEY=your-openai-api-key-here
```

If you skip this, the LLM features will be disabled.

## Step 7: Run Deployment

```bash
# Make script executable
chmod +x deploy.sh

# Edit the script to set PROJECT_ID if not using environment variable
# Or set it as shown in Step 3

# Run deployment
./deploy.sh
```

Or deploy manually:

```bash
# Build and deploy backend
cd backend
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-backend:latest

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

# Build and deploy frontend
cd ../frontend
docker build --build-arg NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL -t gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest

gcloud run deploy pdf-chatbot-frontend \
  --image gcr.io/$PROJECT_ID/pdf-chatbot-frontend:latest \
  --region $REGION \
  --platform managed \
  --allow-unauthenticated \
  --memory 512Mi \
  --set-env-vars NEXT_PUBLIC_BACKEND_URL=$BACKEND_URL

# Get URLs
echo "Frontend: $(gcloud run services describe pdf-chatbot-frontend --region $REGION --format 'value(status.url)')"
echo "Backend: $BACKEND_URL"
```

## Advantages of Cloud Shell

✅ No local installation needed  
✅ Pre-configured with all tools  
✅ Authenticated automatically  
✅ Free 5GB persistent storage  
✅ Works from any computer  

## Notes

- Cloud Shell sessions persist for 20 minutes of inactivity
- Files in your home directory persist across sessions
- You can install additional tools if needed
- Consider using Git to manage your code



