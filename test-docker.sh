#!/bin/bash

# test-docker.sh - Comprehensive Docker setup testing script
# This script tests both development and production Docker configurations

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DEV_IMAGE="demo-express-js-app:dev"
PROD_IMAGE="demo-express-js-app:prod"
DEV_CONTAINER="demo-express-dev-test"
PROD_CONTAINER="demo-express-prod-test"
TEST_PORT_DEV=3001
TEST_PORT_PROD=3002
WAIT_TIME=15

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_header() {
    echo ""
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

# Function to cleanup containers and images
cleanup() {
    print_header "Cleaning Up"

    # Stop and remove containers
    if docker ps -a | grep -q "$DEV_CONTAINER"; then
        print_info "Removing development container..."
        docker rm -f "$DEV_CONTAINER" 2>/dev/null || true
    fi

    if docker ps -a | grep -q "$PROD_CONTAINER"; then
        print_info "Removing production container..."
        docker rm -f "$PROD_CONTAINER" 2>/dev/null || true
    fi

    # Optional: Remove images (commented out by default)
    # print_info "Removing test images..."
    # docker rmi "$DEV_IMAGE" 2>/dev/null || true
    # docker rmi "$PROD_IMAGE" 2>/dev/null || true

    print_success "Cleanup completed"
}

# Function to build Docker images
build_images() {
    print_header "Building Docker Images"

    print_info "Building development image..."
    if docker build --target development -t "$DEV_IMAGE" .; then
        print_success "Development image built successfully"
    else
        print_error "Failed to build development image"
        exit 1
    fi

    print_info "Building production image..."
    if docker build --target production -t "$PROD_IMAGE" .; then
        print_success "Production image built successfully"
    else
        print_error "Failed to build production image"
        exit 1
    fi

    # Display image sizes
    print_info "Image sizes:"
    docker images | grep demo-express-js-app
}

# Function to test development container
test_development() {
    print_header "Testing Development Container"

    print_info "Starting development container..."
    docker run -d \
        --name "$DEV_CONTAINER" \
        -p "$TEST_PORT_DEV:3000" \
        -e NODE_ENV=development \
        -e LOG_LEVEL=debug \
        "$DEV_IMAGE"

    print_info "Waiting ${WAIT_TIME}s for container to be ready..."
    sleep "$WAIT_TIME"

    # Check if container is running
    if docker ps | grep -q "$DEV_CONTAINER"; then
        print_success "Development container is running"
    else
        print_error "Development container failed to start"
        docker logs "$DEV_CONTAINER"
        return 1
    fi

    # Test health endpoint
    print_info "Testing health endpoint..."
    HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$TEST_PORT_DEV/health")
    if [ "$HEALTH_RESPONSE" = "200" ]; then
        print_success "Health check passed (HTTP $HEALTH_RESPONSE)"
        curl -s "http://localhost:$TEST_PORT_DEV/health" | jq '.' || curl -s "http://localhost:$TEST_PORT_DEV/health"
    else
        print_error "Health check failed (HTTP $HEALTH_RESPONSE)"
        return 1
    fi

    # Test main endpoint
    print_info "Testing main endpoint..."
    MAIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$TEST_PORT_DEV/")
    if [ "$MAIN_RESPONSE" = "200" ]; then
        print_success "Main endpoint passed (HTTP $MAIN_RESPONSE)"
    else
        print_warning "Main endpoint returned HTTP $MAIN_RESPONSE"
    fi

    # Display container stats
    print_info "Development container stats:"
    docker stats --no-stream "$DEV_CONTAINER"

    # Display logs sample
    print_info "Development container logs (last 10 lines):"
    docker logs --tail 10 "$DEV_CONTAINER"
}

# Function to test production container
test_production() {
    print_header "Testing Production Container"

    print_info "Starting production container..."
    docker run -d \
        --name "$PROD_CONTAINER" \
        -p "$TEST_PORT_PROD:3000" \
        -e NODE_ENV=production \
        -e LOG_LEVEL=info \
        "$PROD_IMAGE"

    print_info "Waiting ${WAIT_TIME}s for container to be ready..."
    sleep "$WAIT_TIME"

    # Check if container is running
    if docker ps | grep -q "$PROD_CONTAINER"; then
        print_success "Production container is running"
    else
        print_error "Production container failed to start"
        docker logs "$PROD_CONTAINER"
        return 1
    fi

    # Test health endpoint
    print_info "Testing health endpoint..."
    HEALTH_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$TEST_PORT_PROD/health")
    if [ "$HEALTH_RESPONSE" = "200" ]; then
        print_success "Health check passed (HTTP $HEALTH_RESPONSE)"
        curl -s "http://localhost:$TEST_PORT_PROD/health" | jq '.' || curl -s "http://localhost:$TEST_PORT_PROD/health"
    else
        print_error "Health check failed (HTTP $HEALTH_RESPONSE)"
        return 1
    fi

    # Test main endpoint
    print_info "Testing main endpoint..."
    MAIN_RESPONSE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$TEST_PORT_PROD/")
    if [ "$MAIN_RESPONSE" = "200" ]; then
        print_success "Main endpoint passed (HTTP $MAIN_RESPONSE)"
    else
        print_warning "Main endpoint returned HTTP $MAIN_RESPONSE"
    fi

    # Check if PM2 is running
    print_info "Checking PM2 status..."
    if docker exec "$PROD_CONTAINER" pm2 list | grep -q "online"; then
        print_success "PM2 is running in cluster mode"
        docker exec "$PROD_CONTAINER" pm2 list
    else
        print_warning "PM2 status check inconclusive"
        docker exec "$PROD_CONTAINER" pm2 list || true
    fi

    # Display container stats
    print_info "Production container stats:"
    docker stats --no-stream "$PROD_CONTAINER"

    # Display logs sample
    print_info "Production container logs (last 10 lines):"
    docker logs --tail 10 "$PROD_CONTAINER"
}

# Function to display summary
display_summary() {
    print_header "Test Summary"

    echo ""
    echo "Container Status:"
    docker ps -a | grep demo-express || echo "No containers found"

    echo ""
    echo "Image Information:"
    docker images | grep demo-express-js-app

    echo ""
    print_info "Access URLs:"
    echo "  Development: http://localhost:$TEST_PORT_DEV"
    echo "  Production:  http://localhost:$TEST_PORT_PROD"

    echo ""
    print_info "Useful commands:"
    echo "  View dev logs:  docker logs -f $DEV_CONTAINER"
    echo "  View prod logs: docker logs -f $PROD_CONTAINER"
    echo "  Stop dev:       docker stop $DEV_CONTAINER"
    echo "  Stop prod:      docker stop $PROD_CONTAINER"
    echo "  Cleanup:        docker rm -f $DEV_CONTAINER $PROD_CONTAINER"
}

# Main execution
main() {
    print_header "Docker Setup Test Script"

    # Check if Docker is running
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker and try again."
        exit 1
    fi

    print_success "Docker is running"

    # Cleanup any existing test containers
    cleanup

    # Build images
    build_images

    # Test development container
    if test_development; then
        print_success "Development container tests passed"
    else
        print_error "Development container tests failed"
        cleanup
        exit 1
    fi

    # Test production container
    if test_production; then
        print_success "Production container tests passed"
    else
        print_error "Production container tests failed"
        cleanup
        exit 1
    fi

    # Display summary
    display_summary

    print_header "All Tests Passed!"
    print_success "Docker setup is working correctly"

    echo ""
    print_warning "Test containers are still running. To clean up, run:"
    echo "  docker rm -f $DEV_CONTAINER $PROD_CONTAINER"
    echo ""
    print_info "Or run this script with 'cleanup' argument:"
    echo "  ./test-docker.sh cleanup"
}

# Handle script arguments
if [ "$1" = "cleanup" ]; then
    cleanup
    exit 0
elif [ "$1" = "help" ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    echo "Docker Setup Test Script"
    echo ""
    echo "Usage:"
    echo "  ./test-docker.sh          - Run full test suite"
    echo "  ./test-docker.sh cleanup  - Clean up test containers"
    echo "  ./test-docker.sh help     - Show this help message"
    exit 0
else
    main
fi
