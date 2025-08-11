# HR MCP Server - Cloud Run Deployment

This guide will help you deploy your HR MCP Server to Google Cloud Run.

## Prerequisites

1. **Google Cloud Account**: Make sure you have a Google Cloud account with billing enabled
2. **Google Cloud CLI**: Install the [gcloud CLI](https://cloud.google.com/sdk/docs/install)
3. **Docker**: Install [Docker Desktop](https://www.docker.com/products/docker-desktop/)
4. **Authentication**: Authenticate with Google Cloud:
   ```bash
   gcloud auth login
   gcloud auth configure-docker
   ```

## Deployment Steps

### Option 1: Using the Deployment Script (Recommended)

1. **Update Configuration**: Edit the deployment script (`deploy-to-cloudrun.ps1` for Windows or `deploy-to-cloudrun.sh` for Linux/Mac) and update these variables:
   ```powershell
   $PROJECT_ID = "your-actual-gcp-project-id"
   $SERVICE_NAME = "hr-mcp-server"  # You can change this if needed
   $REGION = "us-central1"          # Choose your preferred region
   ```

2. **Run the Deployment Script**:
   
   **For Windows (PowerShell):**
   ```powershell
   .\deploy-to-cloudrun.ps1
   ```
   
   **For Linux/Mac (Bash):**
   ```bash
   chmod +x deploy-to-cloudrun.sh
   ./deploy-to-cloudrun.sh
   ```

### Option 2: Manual Deployment

1. **Set your project ID**:
   ```bash
   export PROJECT_ID="your-gcp-project-id"
   gcloud config set project $PROJECT_ID
   ```

2. **Enable required APIs**:
   ```bash
   gcloud services enable cloudbuild.googleapis.com
   gcloud services enable run.googleapis.com
   ```

3. **Build the Docker image**:
   ```bash
   docker build -t gcr.io/$PROJECT_ID/hr-mcp-server .
   ```

4. **Push the image**:
   ```bash
   docker push gcr.io/$PROJECT_ID/hr-mcp-server
   ```

5. **Deploy to Cloud Run**:
   ```bash
   gcloud run deploy hr-mcp-server \
     --image gcr.io/$PROJECT_ID/hr-mcp-server \
     --platform managed \
     --region us-central1 \
     --allow-unauthenticated \
     --port 8080 \
     --memory 256Mi \
     --cpu 0.25 \
     --min-instances 0 \
     --max-instances 1
   ```

## Configuration

### Environment Variables

The application uses the following configuration:

- **Port**: 8080 (required by Cloud Run)
- **Candidates Data**: Located at `./Data/candidates.json`
- **Environment**: Production

### Customizing the Deployment

You can modify the Cloud Run deployment by adjusting these parameters:

- `--memory`: Memory allocation (256Mi, 512Mi, 1Gi, 2Gi, 4Gi, 8Gi)
- `--cpu`: CPU allocation (0.25, 0.5, 1, 2, 4, 6, 8)
- `--min-instances`: Minimum number of instances (0 for cost optimization)
- `--max-instances`: Maximum number of instances
- `--concurrency`: Maximum concurrent requests per instance
- `--timeout`: Request timeout in seconds

## Testing Your Deployment

After deployment, you'll receive a URL like: `https://hr-mcp-server-xxxxx-uc.a.run.app`

You can test your MCP server by:

1. **Health Check**: Visit the URL in your browser
2. **MCP Protocol**: Use an MCP client to connect to the server
3. **API Testing**: Use tools like curl or Postman to test the endpoints

## Monitoring and Logs

- **View logs**: 
  ```bash
  gcloud logs read "resource.type=cloud_run_revision AND resource.labels.service_name=hr-mcp-server" --limit 50
  ```

- **Monitor in Console**: Visit the [Cloud Run section](https://console.cloud.google.com/run) in Google Cloud Console

## Security Considerations

The current deployment allows unauthenticated access (`--allow-unauthenticated`). For production use, consider:

1. **Remove unauthenticated access**:
   ```bash
   gcloud run services remove-iam-policy-binding hr-mcp-server \
     --member="allUsers" \
     --role="roles/run.invoker" \
     --region=us-central1
   ```

2. **Add specific users/service accounts**:
   ```bash
   gcloud run services add-iam-policy-binding hr-mcp-server \
     --member="user:your-email@domain.com" \
     --role="roles/run.invoker" \
     --region=us-central1
   ```

## Updating Your Service

To update your service with new code:

1. Rebuild and push the Docker image
2. Deploy again with the same command (Cloud Run will automatically update)

## Cost Optimization

- Cloud Run charges only for requests and CPU time used
- Set `--min-instances 0` to avoid charges when not in use
- Monitor usage in the Google Cloud Console

## Troubleshooting

### Common Issues:

1. **Authentication errors**: Run `gcloud auth login` and `gcloud auth configure-docker`
2. **Permission errors**: Ensure you have the necessary IAM roles (Cloud Run Admin, Storage Admin)
3. **Build failures**: Check Docker is running and the Dockerfile syntax
4. **Memory errors**: Increase memory allocation in the deployment command

### Getting Help:

- Check logs: `gcloud logs read "resource.type=cloud_run_revision"`
- View service details: `gcloud run services describe hr-mcp-server --region us-central1`

## Files Created for Deployment

- `Dockerfile`: Defines how to build the container image
- `.dockerignore`: Specifies files to exclude from the Docker build context
- `appsettings.json`: Production configuration
- `deploy-to-cloudrun.ps1`: PowerShell deployment script
- `deploy-to-cloudrun.sh`: Bash deployment script
- `DEPLOYMENT.md`: This documentation file
