# Cloud Run Deployment Script for HR MCP Server (PowerShell)
# Make sure you have gcloud CLI installed and authenticated

# Configuration variables - Update these with your values
$PROJECT_ID = "your-gcp-project-id"
$SERVICE_NAME = "hr-mcp-server"
$REGION = "us-central1"
$IMAGE_NAME = "gcr.io/$PROJECT_ID/$SERVICE_NAME"

Write-Host "Starting deployment of HR MCP Server to Cloud Run..." -ForegroundColor Yellow

# Check if gcloud is installed
if (!(Get-Command gcloud -ErrorAction SilentlyContinue)) {
    Write-Host "gcloud CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if Docker is running
try {
    docker info | Out-Null
} catch {
    Write-Host "Docker is not running. Please start Docker first." -ForegroundColor Red
    exit 1
}

# Set the project
Write-Host "Setting GCP project to $PROJECT_ID..." -ForegroundColor Yellow
gcloud config set project $PROJECT_ID

# Enable required APIs
Write-Host "Enabling required APIs..." -ForegroundColor Yellow
gcloud services enable cloudbuild.googleapis.com
gcloud services enable run.googleapis.com

# Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
docker build -t $IMAGE_NAME .

# Push the image to Google Container Registry
Write-Host "Pushing image to Google Container Registry..." -ForegroundColor Yellow
docker push $IMAGE_NAME

# Deploy to Cloud Run
Write-Host "Deploying to Cloud Run..." -ForegroundColor Yellow
gcloud run deploy $SERVICE_NAME `
    --image $IMAGE_NAME `
    --platform managed `
    --region $REGION `
    --allow-unauthenticated `
    --port 8080 `
    --memory 256Mi `
    --cpu 0.25 `
    --min-instances 0 `
    --max-instances 1 `
    --timeout 300 `
    --concurrency 80

# Get the service URL
$SERVICE_URL = (gcloud run services describe $SERVICE_NAME --platform managed --region $REGION --format 'value(status.url)')

Write-Host "Deployment completed successfully!" -ForegroundColor Green
Write-Host "Service URL: $SERVICE_URL" -ForegroundColor Green
Write-Host "You can test your MCP server at: $SERVICE_URL" -ForegroundColor Yellow

# Optional: Show service details
Write-Host "`nService details:" -ForegroundColor Yellow
gcloud run services describe $SERVICE_NAME --platform managed --region $REGION
