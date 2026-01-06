# Step-by-Step Guide: Running the Application

Follow these steps to build and run the single application.

## Prerequisites Check

Before starting, make sure you have:
- ✅ Node.js installed (version 16 or higher)
- ✅ npm installed (comes with Node.js)
- ✅ Java 17 installed
- ✅ Maven installed

Check your installations:
```bash
node --version    # Should show v16+ or v18+
npm --version     # Should show version number
java -version     # Should show Java 17
mvn --version     # Should show Maven version
```

## Step-by-Step Instructions

### Step 1: Open Terminal

Open your terminal/command prompt and navigate to the project directory:

```bash
cd /Users/sriharshagorla/Desktop/pdf-chatbot-starter
```

Or if you're already in a different location:
```bash
cd ~/Desktop/pdf-chatbot-starter
```

### Step 2: Make the Script Executable

Make sure the script has execute permissions:

```bash
chmod +x build-and-run.sh
```

**What this does:** Gives the script permission to run.

### Step 3: Verify the Script Exists

Check that the script is there:

```bash
ls -la build-and-run.sh
```

You should see the file listed. If you get "No such file", make sure you're in the correct directory.

### Step 4: Run the Script

Execute the build and run script:

```bash
./build-and-run.sh
```

**What happens:**
1. The script builds the Next.js frontend (this takes 1-2 minutes)
2. Copies the built files to Spring Boot resources
3. Builds the Spring Boot JAR file
4. Starts the application

### Step 5: Wait for Build to Complete

You'll see output like this:

```
==========================================
Building Single Application
==========================================

Step 1: Building Next.js frontend...
Installing npm dependencies... (if needed)
Building frontend (this may take a minute)...
✓ Frontend built successfully

Step 2: Copying frontend to backend resources...
✓ Frontend files copied to backend

Step 3: Building Spring Boot application...
[INFO] Building pdf-chatbot 0.0.1
...
✓ Spring Boot built successfully

==========================================
Build Complete!
==========================================

Starting application...
Access at: http://localhost:8080
```

### Step 6: Access the Application

Once you see "Started PdfChatbotApplication", open your browser and go to:

**http://localhost:8080**

You should see the PDF Chatbot interface!

### Step 7: Stop the Application

When you're done, press:

```
Ctrl + C
```

This stops the Spring Boot server.

## Troubleshooting

### Issue: "Permission denied" when running script

**Solution:**
```bash
chmod +x build-and-run.sh
```

### Issue: "npm: command not found"

**Solution:** Install Node.js from https://nodejs.org/

### Issue: "mvn: command not found"

**Solution:** Install Maven:
- **macOS:** `brew install maven`
- **Linux:** `sudo apt-get install maven`
- **Windows:** Download from https://maven.apache.org/

### Issue: "java: command not found"

**Solution:** Install Java 17:
- **macOS:** `brew install openjdk@17`
- **Linux:** `sudo apt-get install openjdk-17-jdk`
- **Windows:** Download from https://adoptium.net/

### Issue: Frontend build fails

**Solution:**
```bash
cd frontend
rm -rf node_modules package-lock.json
npm install
npm run build
```

### Issue: Port 8080 already in use

**Solution:** Stop any other application using port 8080, or change the port in `backend/src/main/resources/application.properties`:
```properties
server.port=8081
```

### Issue: Still seeing Whitelabel Error Page

**Solution:** Make sure the frontend was built and copied:
```bash
# Check if static files exist
ls -la backend/src/main/resources/static/

# If empty or missing, rebuild:
cd frontend
npm run build
cd ..
mkdir -p backend/src/main/resources/static
cp -r frontend/out/* backend/src/main/resources/static/
cd backend
mvn clean package
java -jar target/pdf-chatbot-0.0.1.jar
```

## Alternative: Manual Steps (if script doesn't work)

If the script has issues, you can do it manually:

```bash
# 1. Build frontend
cd frontend
npm install
npm run build

# 2. Copy to backend
cd ..
mkdir -p backend/src/main/resources/static
cp -r frontend/out/* backend/src/main/resources/static/

# 3. Build backend
cd backend
mvn clean package

# 4. Run
java -jar target/pdf-chatbot-0.0.1.jar
```

## Quick Reference

| Command | What it does |
|---------|-------------|
| `./build-and-run.sh` | Builds and runs the application |
| `Ctrl+C` | Stops the application |
| `http://localhost:8080` | Access the application in browser |

## What's Next?

Once the application is running:
1. Place PDF files in the `pdfs/` folder
2. Click "Reload PDFs" in the UI
3. Ask questions about your PDFs!


