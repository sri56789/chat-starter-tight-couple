# Local Development Setup

## The Problem

You're seeing a "Whitelabel Error Page" because the frontend static files haven't been built and copied to Spring Boot's resources directory.

## Quick Fix

Run these commands in order:

### Step 1: Build the Frontend

```bash
cd frontend
npm install  # if you haven't already
npm run build
```

This creates a `frontend/out` directory with the static HTML/CSS/JS files.

### Step 2: Copy to Spring Boot Resources

```bash
# From project root
mkdir -p backend/src/main/resources/static
cp -r frontend/out/* backend/src/main/resources/static/
```

### Step 3: Build and Run Spring Boot

```bash
cd backend
mvn clean package
java -jar target/pdf-chatbot-0.0.1.jar
```

Then open: http://localhost:8080

## Using the Build Script

Alternatively, use the build script (if permissions allow):

```bash
./build-local.sh
```

Then run:
```bash
cd backend
java -jar target/pdf-chatbot-0.0.1.jar
```

## Verify Files Were Copied

Check that files exist:
```bash
ls -la backend/src/main/resources/static/
```

You should see `index.html` and other files there.

## Troubleshooting

### Still seeing Whitelabel Error?

1. **Check static files exist:**
   ```bash
   ls backend/src/main/resources/static/index.html
   ```
   If this file doesn't exist, the copy step failed.

2. **Rebuild everything:**
   ```bash
   # Clean frontend
   cd frontend
   rm -rf .next out
   npm run build
   
   # Clean backend
   cd ../backend
   rm -rf target
   rm -rf src/main/resources/static
   
   # Copy and build
   mkdir -p src/main/resources/static
   cp -r ../frontend/out/* src/main/resources/static/
   mvn clean package
   ```

3. **Check the JAR contains static files:**
   ```bash
   jar tf backend/target/pdf-chatbot-0.0.1.jar | grep static
   ```
   You should see files like `BOOT-INF/classes/static/index.html`

## Development Workflow

For development, you have two options:

### Option A: Run Frontend and Backend Separately (Recommended for Development)

**Terminal 1 - Backend:**
```bash
cd backend
mvn spring-boot:run
```

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```

Access:
- Frontend: http://localhost:3000 (will proxy to backend)
- Backend API: http://localhost:8080/api

### Option B: Single App (Current Setup)

Build both and run as single app:
```bash
./build-local.sh
cd backend
java -jar target/pdf-chatbot-0.0.1.jar
```

Access:
- App: http://localhost:8080


