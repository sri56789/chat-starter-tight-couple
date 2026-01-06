# Quick Start - Single Spring Boot App

## ✅ What Changed

- **Single application**: Frontend and backend are now one Spring Boot app
- **Fixed Docker build**: Uses `eclipse-temurin:17-jre-jammy` (not alpine)
- **Simpler deployment**: One container, one service
- **No CORS issues**: Same origin for UI and API

## 🚀 Build & Run Locally

```bash
# Build the application
cd backend
mvn clean package

# Run it
java -jar target/pdf-chatbot-0.0.1.jar

# Open browser: http://localhost:8080
```

## 🐳 Build Docker Image

```bash
# From project root
docker build -t pdf-chatbot:latest .
```

The Dockerfile uses multi-stage build:
1. Builds Next.js frontend
2. Copies to Spring Boot resources
3. Builds Spring Boot JAR
4. Creates runtime image

## ☁️ Deploy to Google Cloud

```bash
export GCP_PROJECT_ID=your-project-id
export LLM_API_KEY=your-api-key
./deploy-single.sh
```

Or manually:

```bash
# Build and push
docker build -t gcr.io/$PROJECT_ID/pdf-chatbot:latest .
docker push gcr.io/$PROJECT_ID/pdf-chatbot:latest

# Deploy
gcloud run deploy pdf-chatbot \
  --image gcr.io/$PROJECT_ID/pdf-chatbot:latest \
  --region us-central1 \
  --allow-unauthenticated \
  --memory 2Gi \
  --set-env-vars LLM_API_KEY=$LLM_API_KEY
```

## 📁 Project Structure

```
pdf-chatbot-starter/
├── backend/              # Spring Boot app
│   └── src/main/
│       └── resources/
│           └── static/   # Frontend files (generated)
├── frontend/             # Next.js source
├── Dockerfile           # Single multi-stage build
└── deploy-single.sh     # Deployment script
```

## 🔧 Configuration

- API endpoints: `/api/*`
- Static files: Everything else
- Port: `8080`
- Frontend: Served from `/static/` in resources

## 🎯 Benefits

1. **Simpler**: One JAR, one container, one service
2. **Fixed Docker**: Uses jammy base image (fixes alpine issue)
3. **No CORS**: Same origin
4. **Easier deployment**: Single command
5. **Lower cost**: One Cloud Run service


