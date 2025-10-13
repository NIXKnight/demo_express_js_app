# Docker Commands Reference

Comprehensive reference guide for Docker operations with this Express.js application.

## Table of Contents

1. [Build Commands](#build-commands)
2. [Run Commands](#run-commands)
3. [Docker Compose Commands](#docker-compose-commands)
4. [Container Management](#container-management)
5. [Image Management](#image-management)
6. [Debugging Commands](#debugging-commands)
7. [Health Check Commands](#health-check-commands)
8. [Logs and Monitoring](#logs-and-monitoring)
9. [Registry Operations](#registry-operations)
10. [Network Commands](#network-commands)
11. [Volume Commands](#volume-commands)
12. [Cleanup Commands](#cleanup-commands)
13. [Troubleshooting](#troubleshooting)
14. [CI/CD Integration](#cicd-integration)

---

## Build Commands

### Build Development Image
```bash
# Build development image
docker build --target development -t demo-express-js-app:dev .

# Build with no cache
docker build --target development --no-cache -t demo-express-js-app:dev .

# Build with build arguments
docker build --target development --build-arg NODE_VERSION=20 -t demo-express-js-app:dev .
```

### Build Production Image
```bash
# Build production image
docker build --target production -t demo-express-js-app:prod .

# Build with version tag
docker build --target production -t demo-express-js-app:1.0.0 -t demo-express-js-app:latest .

# Build with platform specification
docker build --target production --platform linux/amd64 -t demo-express-js-app:prod .
```

### Multi-Stage Build Commands
```bash
# Build specific stage
docker build --target base -t demo-express-js-app:base .
docker build --target dependencies -t demo-express-js-app:deps .
docker build --target production-dependencies -t demo-express-js-app:prod-deps .

# View build history
docker history demo-express-js-app:prod

# Check image size
docker images demo-express-js-app
```

---

## Run Commands

### Run Development Container
```bash
# Run development container
docker run -d -p 3000:3000 --name express-dev demo-express-js-app:dev

# Run with environment variables
docker run -d -p 3000:3000 \
  -e NODE_ENV=development \
  -e LOG_LEVEL=debug \
  --name express-dev \
  demo-express-js-app:dev

# Run with volume mounts (hot-reload)
docker run -d -p 3000:3000 \
  -v $(pwd):/app \
  -v /app/node_modules \
  --name express-dev \
  demo-express-js-app:dev

# Run in interactive mode
docker run -it -p 3000:3000 --name express-dev demo-express-js-app:dev
```

### Run Production Container
```bash
# Run production container
docker run -d -p 3000:3000 --name express-prod demo-express-js-app:prod

# Run with resource limits
docker run -d -p 3000:3000 \
  --cpus="2" \
  --memory="1g" \
  --name express-prod \
  demo-express-js-app:prod

# Run with restart policy
docker run -d -p 3000:3000 \
  --restart=always \
  --name express-prod \
  demo-express-js-app:prod

# Run with custom network
docker run -d -p 3000:3000 \
  --network=app-network \
  --name express-prod \
  demo-express-js-app:prod
```

---

## Docker Compose Commands

### Basic Operations
```bash
# Start development environment
docker-compose up app-dev

# Start production environment
docker-compose up app-prod

# Start in detached mode
docker-compose up -d app-prod

# Start with build
docker-compose up --build app-prod

# Start all services
docker-compose up -d
```

### Stop and Remove
```bash
# Stop services
docker-compose stop

# Stop specific service
docker-compose stop app-prod

# Stop and remove containers
docker-compose down

# Stop, remove, and delete volumes
docker-compose down -v

# Stop, remove, and delete images
docker-compose down --rmi all
```

### Rebuild and Restart
```bash
# Rebuild without cache
docker-compose build --no-cache

# Rebuild specific service
docker-compose build app-prod

# Restart service
docker-compose restart app-prod

# Force recreate containers
docker-compose up -d --force-recreate
```

---

## Container Management

### Start/Stop Containers
```bash
# Start container
docker start express-prod

# Stop container
docker stop express-prod

# Restart container
docker restart express-prod

# Pause container
docker pause express-prod

# Unpause container
docker unpause express-prod

# Kill container
docker kill express-prod
```

### Inspect Containers
```bash
# List running containers
docker ps

# List all containers
docker ps -a

# Inspect container
docker inspect express-prod

# View container stats
docker stats express-prod

# View container processes
docker top express-prod

# View container resource usage
docker stats --no-stream
```

### Execute Commands in Container
```bash
# Execute command in running container
docker exec express-prod ls -la

# Open shell in container
docker exec -it express-prod sh

# Run as root user
docker exec -u root -it express-prod sh

# Check Node.js version
docker exec express-prod node --version

# Check PM2 status
docker exec express-prod pm2 status
```

---

## Image Management

### List and Inspect Images
```bash
# List images
docker images

# List with digests
docker images --digests

# Filter images
docker images demo-express-js-app

# Inspect image
docker inspect demo-express-js-app:prod

# View image layers
docker history demo-express-js-app:prod
```

### Tag and Remove Images
```bash
# Tag image
docker tag demo-express-js-app:prod demo-express-js-app:1.0.0

# Remove image
docker rmi demo-express-js-app:dev

# Force remove image
docker rmi -f demo-express-js-app:dev

# Remove unused images
docker image prune

# Remove all unused images
docker image prune -a
```

---

## Debugging Commands

### View Logs
```bash
# View container logs
docker logs express-prod

# Follow logs (tail -f)
docker logs -f express-prod

# View last 100 lines
docker logs --tail 100 express-prod

# View logs with timestamps
docker logs -t express-prod

# View logs since specific time
docker logs --since 10m express-prod
```

### Attach to Container
```bash
# Attach to container output
docker attach express-prod

# Copy files from container
docker cp express-prod:/app/logs/pm2-error.log ./local-logs/

# Copy files to container
docker cp ./config.json express-prod:/app/config.json
```

### Troubleshooting
```bash
# Check container events
docker events --filter container=express-prod

# View port mappings
docker port express-prod

# Check container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' express-prod

# View environment variables
docker exec express-prod env
```

---

## Health Check Commands

### Check Container Health
```bash
# View health status
docker inspect --format='{{.State.Health.Status}}' express-prod

# View health check logs
docker inspect --format='{{json .State.Health}}' express-prod | jq

# Manual health check
docker exec express-prod node -e "require('http').get('http://localhost:3000/health', (r) => {console.log(r.statusCode)})"

# Test health endpoint from host
curl http://localhost:3000/health

# Test health with detailed output
curl -v http://localhost:3000/health
```

---

## Logs and Monitoring

### Container Logs
```bash
# Stream logs from Docker Compose
docker-compose logs -f app-prod

# View logs from specific service
docker-compose logs app-prod

# View logs with timestamps
docker-compose logs -t app-prod

# View specific number of lines
docker-compose logs --tail=50 app-prod
```

### Monitoring
```bash
# Real-time resource monitoring
docker stats

# Monitor specific container
docker stats express-prod

# Monitor with custom format
docker stats --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}"

# View disk usage
docker system df

# Detailed disk usage
docker system df -v
```

---

## Registry Operations

### Docker Hub
```bash
# Login to Docker Hub
docker login

# Tag for Docker Hub
docker tag demo-express-js-app:prod username/demo-express-js-app:latest
docker tag demo-express-js-app:prod username/demo-express-js-app:1.0.0

# Push to Docker Hub
docker push username/demo-express-js-app:latest
docker push username/demo-express-js-app:1.0.0

# Pull from Docker Hub
docker pull username/demo-express-js-app:latest

# Logout
docker logout
```

### Private Registry
```bash
# Tag for private registry
docker tag demo-express-js-app:prod registry.example.com/demo-express-js-app:latest

# Login to private registry
docker login registry.example.com

# Push to private registry
docker push registry.example.com/demo-express-js-app:latest

# Pull from private registry
docker pull registry.example.com/demo-express-js-app:latest
```

---

## Network Commands

### Network Management
```bash
# List networks
docker network ls

# Create network
docker network create app-network

# Inspect network
docker network inspect app-network

# Connect container to network
docker network connect app-network express-prod

# Disconnect container from network
docker network disconnect app-network express-prod

# Remove network
docker network rm app-network

# Prune unused networks
docker network prune
```

---

## Volume Commands

### Volume Management
```bash
# List volumes
docker volume ls

# Create volume
docker volume create app-logs

# Inspect volume
docker volume inspect app-logs

# Remove volume
docker volume rm app-logs

# Prune unused volumes
docker volume prune

# Run with named volume
docker run -d -p 3000:3000 -v app-logs:/app/logs demo-express-js-app:prod
```

---

## Cleanup Commands

### Remove Containers
```bash
# Remove stopped container
docker rm express-prod

# Force remove running container
docker rm -f express-prod

# Remove all stopped containers
docker container prune

# Remove all containers (including running)
docker rm -f $(docker ps -aq)
```

### System Cleanup
```bash
# Remove all unused objects
docker system prune

# Remove all unused images
docker system prune -a

# Remove all with volumes
docker system prune -a --volumes

# View reclaimable space
docker system df
```

---

## Troubleshooting

### Common Issues

**Container won't start:**
```bash
# Check logs
docker logs express-prod

# Inspect container
docker inspect express-prod

# Check exit code
docker inspect express-prod --format='{{.State.ExitCode}}'
```

**Port already in use:**
```bash
# Find process using port
lsof -i :3000
netstat -tulpn | grep 3000

# Use different port
docker run -p 3001:3000 demo-express-js-app:prod
```

**Permission issues:**
```bash
# Check file ownership in container
docker exec express-prod ls -la /app

# Run as root to debug
docker exec -u root -it express-prod sh
```

**Build failures:**
```bash
# Build with verbose output
docker build --progress=plain -t demo-express-js-app:prod .

# Check Dockerfile syntax
docker build --check .

# Build without cache
docker build --no-cache -t demo-express-js-app:prod .
```

**Network issues:**
```bash
# Check container IP
docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' express-prod

# Test connectivity
docker exec express-prod ping google.com

# Check DNS
docker exec express-prod nslookup google.com
```

---

## CI/CD Integration

### GitHub Actions
```yaml
name: Docker Build and Push

on:
  push:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_PASSWORD }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          target: production
          push: true
          tags: |
            username/demo-express-js-app:latest
            username/demo-express-js-app:${{ github.sha }}
```

### GitLab CI
```yaml
docker-build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker login -u $CI_REGISTRY_USER -p $CI_REGISTRY_PASSWORD $CI_REGISTRY
    - docker build --target production -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  only:
    - main
```

### Jenkins
```groovy
pipeline {
    agent any
    stages {
        stage('Build') {
            steps {
                sh 'docker build --target production -t demo-express-js-app:prod .'
            }
        }
        stage('Test') {
            steps {
                sh 'docker run --rm demo-express-js-app:prod npm test'
            }
        }
        stage('Push') {
            steps {
                sh 'docker push username/demo-express-js-app:latest'
            }
        }
    }
}
```

---

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
- [Dockerfile Best Practices](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/)
- [Multi-Stage Builds](https://docs.docker.com/build/building/multi-stage/)
- [Docker Security](https://docs.docker.com/engine/security/)

---

**Last Updated**: 2025-10-13
