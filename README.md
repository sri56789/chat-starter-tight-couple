# PDF Chatbot Starter

A full-stack application that allows you to chat with your PDF documents. Ask questions about the content in your PDFs and get AI-powered answers.

## Project Structure

```
pdf-chatbot-starter/
├── backend/          # Spring Boot Java backend
├── frontend/         # Next.js React frontend
└── pdfs/            # Place your training PDFs here
```

## Setup Instructions

### Backend (Spring Boot)

1. Navigate to the backend directory:
   ```bash
   cd backend
   ```

2. **Configure LLM API Key** (Required for intelligent answers):
   
   Option A: Set environment variable:
   ```bash
   export LLM_API_KEY=your-openai-api-key-here
   ```
   
   Option B: Edit `src/main/resources/application.properties`:
   ```properties
   llm.api.key=your-openai-api-key-here
   ```
   
   Get your OpenAI API key from: https://platform.openai.com/api-keys
   
   Note: If no API key is set, the system will use a fallback text extraction method.

3. Run the application:
   ```bash
   mvn spring-boot:run
   ```
   
   Or use the memory-optimized script:
   ```bash
   ./run.sh
   ```

   The backend will start on `http://localhost:8080`

### Frontend (Next.js)

1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```

2. Install dependencies (if not already done):
   ```bash
   npm install
   ```

3. Run the development server:
   ```bash
   npm run dev
   ```

   The frontend will start on `http://localhost:3000`

## Using the Application

1. **Add PDF Files**: Place your PDF training documents in the `pdfs/` folder
2. **Load PDFs**: Click the "Reload PDFs" button in the UI (or restart the backend)
3. **Ask Questions**: Type questions about the PDF content in the chat interface
4. **Get Answers**: The chatbot will search through your PDFs and provide relevant answers

## Features

- ✅ PDF text extraction using Apache PDFBox
- ✅ Text chunking for efficient search
- ✅ Similarity-based search through PDF content
- ✅ Modern chat interface UI
- ✅ Real-time question answering
- ✅ Support for multiple PDF files

## API Endpoints

- `POST /api/chat` - Send a question and get an answer
  ```json
  {
    "question": "What is the main topic of the document?"
  }
  ```

- `POST /api/reload` - Reload PDF documents from the pdfs folder

## Technologies Used

### Backend
- Spring Boot 3.2.0
- Apache PDFBox 3.0.1 (PDF processing)
- Apache Commons Text (similarity search)
- Spring WebFlux (HTTP client for LLM API calls)
- OpenAI API (GPT-3.5/GPT-4 for answer generation)
- Java 17

### Frontend
- Next.js 14.2.0
- React 18
- TypeScript

## LLM Configuration

The application uses OpenAI's API to generate intelligent answers based on PDF content. You can configure it in `backend/src/main/resources/application.properties`:

```properties
# OpenAI API Key (required)
llm.api.key=your-api-key-here

# Model to use (gpt-3.5-turbo, gpt-4, gpt-4-turbo, etc.)
llm.model=gpt-3.5-turbo

# Enable/disable LLM (set to false for fallback mode)
llm.enabled=true
```

### Alternative LLM Providers

To use a different LLM provider (e.g., Anthropic Claude, local models), modify the `LlmService.java` file to match your provider's API format.

## Notes

- PDFs are loaded when you click "Reload PDFs" (not on startup)
- Large PDFs may take time to process
- The search uses keyword matching and cosine similarity to find relevant content
- LLM generates contextual answers based on the most relevant PDF chunks
- If LLM is disabled or not configured, the system falls back to text extraction

## Deployment to Google Cloud

See [DEPLOY.md](./DEPLOY.md) for detailed instructions on deploying to Google Cloud Platform.

**Quick deployment:**
```bash
export GCP_PROJECT_ID=your-project-id
export LLM_API_KEY=your-api-key
./deploy.sh
```

This will deploy both backend and frontend to Cloud Run.

