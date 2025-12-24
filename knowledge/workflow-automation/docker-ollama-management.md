# Docker Ollama Management

## Container Setup

The setup script creates a persistent Docker container for Ollama:

```bash
# Container name: ollama-screenpal
# Port mapping: 11434:11434
# Volume: ollama-models:/root/.ollama (persistent model storage)
docker run -d --name ollama-screenpal -p 11434:11434 -v ollama-models:/root/.ollama ollama/ollama
```

## Model Management

### Pull Moondream2 Model
```bash
docker exec ollama-screenpal ollama pull moondream2
```

### List Available Models
```bash
docker exec ollama-screenpal ollama list
```

### Remove Models (if needed)
```bash
docker exec ollama-screenpal ollama rm moondream2
```

## Container Management

### Start Container
```bash
docker start ollama-screenpal
```

### Stop Container
```bash
docker stop ollama-screenpal
```

### View Logs
```bash
docker logs ollama-screenpal
```

### Remove Container (will lose models)
```bash
docker rm ollama-screenpal
```

## API Testing

### Check API Status
```bash
curl http://localhost:11434/api/tags
```

### Test Model Availability
```bash
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{"model": "moondream2", "prompt": "Describe this image", "stream": false}'
```

## Troubleshooting

### Container Won't Start
- Check if port 11434 is already in use
- Verify Docker daemon is running
- Check container logs for errors

### Model Download Fails
- Ensure internet connectivity
- Check available disk space
- Verify Docker container has network access

### API Not Responding
- Wait 30-60 seconds after container start
- Check container status: `docker ps`
- Verify port mapping is correct
