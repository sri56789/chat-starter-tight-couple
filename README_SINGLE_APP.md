# Single Application Setup

This application is configured as a **single Spring Boot application** that serves both the frontend UI and backend API from one server.

## 🚀 Quick Start

### Option 1: Build and Run Script (Easiest)

```bash
./build-and-run.sh
```

This script will:
1. Build the Next.js frontend
2. Copy it to Spring Boot resources
3. Build the Spring Boot JAR
4. Start the application

Then open: **http://localhost:8080**

### Option 2: Manual Steps

```bash
# 1. Build frontend
cd frontend
npm install
npm run build

# 2. Copy to backend
cd ..
mkdir -p backend/src/main/resources/static
cp -r frontend/out/* backend/src/main/resources/static/

# 3. Build and run backend
cd backend
mvn clean package
java -jar target/pdf-chatbot-0.0.1.jar
```

## 📁 How It Works

1. **Frontend Build**: Next.js builds static HTML/CSS/JS files to `frontend/out/`
2. **Copy to Resources**: Files are copied to `backend/src/main/resources/static/`
3. **Spring Boot Serves**: Spring Boot serves these static files + API endpoints
4. **Single Endpoint**: Everything runs on `http://localhost:8080`

## 🔧 Architecture

```
┌─────────────────────────────────────┐
│   Spring Boot Application (Port 8080) │
├─────────────────────────────────────┤
│                                     │
│  /api/*  →  REST Controllers        │
│  /*       →  Static Files (Frontend)│
│                                     │
└─────────────────────────────────────┘
```

- **API Routes** (`/api/*`): Handled by `ChatController`
- **Static Routes** (`/*`): Served from `classpath:/static/`
- **SPA Routing**: Non-API routes serve `index.html` for client-side routing

## 📝 Development Workflow

### Rebuilding After Frontend Changes

If you change frontend code:

```bash
# Rebuild frontend
cd frontend
npm run build

# Copy to backend
cd ..
rm -rf backend/src/main/resources/static/*
cp -r frontend/out/* backend/src/main/resources/static/

# Rebuild and run backend
cd backend
mvn clean package
java -jar target/pdf-chatbot-0.0.1.jar
```

Or use the script:
```bash
./build-and-run.sh
```

### Rebuilding After Backend Changes

If you change backend code:

```bash
cd backend
mvn clean package
java -jar target/pdf-chatbot-0.0.1.jar
```

## 🐳 Docker Build

The Dockerfile handles everything automatically:

```bash
docker build -t pdf-chatbot:latest .
docker run -p 8080:8080 pdf-chatbot:latest
```

## ☁️ Deployment

Deploy as a single service:

```bash
./deploy-single.sh
```

This deploys one Cloud Run service serving both UI and API.

## ✅ Benefits

- ✅ **Single endpoint** - No need to manage two servers
- ✅ **No CORS issues** - Same origin for UI and API
- ✅ **Simpler deployment** - One container, one service
- ✅ **Easier development** - One command to start everything
- ✅ **Production-ready** - Static files are optimized and embedded

## 🔍 Troubleshooting

### Whitelabel Error Page

This means static files aren't in the JAR. Make sure you:
1. Built the frontend (`npm run build` in `frontend/`)
2. Copied files to `backend/src/main/resources/static/`
3. Rebuilt the JAR (`mvn clean package`)

### API Routes Not Working

Check that routes start with `/api/`. The WebConfig serves static files for all non-API routes.

### Frontend Changes Not Showing

You need to rebuild and copy the frontend, then rebuild the JAR:
```bash
cd frontend && npm run build
cd .. && cp -r frontend/out/* backend/src/main/resources/static/
cd backend && mvn clean package
```

## 📚 File Structure

```
pdf-chatbot-starter/
├── frontend/
│   ├── app/              # Next.js source
│   └── out/              # Built static files (generated)
├── backend/
│   ├── src/main/
│   │   ├── java/         # Spring Boot code
│   │   └── resources/
│   │       └── static/   # Frontend files (copied from frontend/out/)
│   └── target/
│       └── *.jar         # Final JAR with embedded frontend
└── build-and-run.sh      # Build and run script
```
