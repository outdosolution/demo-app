#!/bin/bash

# =============================================================================
# Demo App Test & Deployment Script
# =============================================================================
# This script tests the demo app locally, then guides you through GitHub setup
# and deployment to production.
# =============================================================================

set -e

DEMO_DIR="/home/ajay/Documents/OCI CID Terrfaorm/demo-app"
REGISTRY="registry.jsoftsolutions.in"
IMAGE_NAME="demo-hello-world"
PRODUCTION_HOST="129.159.21.78"
PRODUCTION_USER="ubuntu"
DEPLOY_PATH="/opt/apps/demo-hello-world"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║  Demo App Test & Deployment Script                        ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# =============================================================================
# Step 1: Test Locally
# =============================================================================
echo -e "${YELLOW}📦 Step 1: Testing Demo App Locally${NC}"
echo ""

cd "$DEMO_DIR"

# Install dependencies
echo "Installing dependencies..."
npm install

# Start server in background
echo "Starting server..."
npm start &
SERVER_PID=$!

# Wait for server to start
sleep 3

# Test endpoints
echo ""
echo -e "${GREEN}Testing endpoints:${NC}"

echo -n "  ✓ Root endpoint (/)... "
if curl -sf http://localhost:3000/ > /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    kill $SERVER_PID
    exit 1
fi

echo -n "  ✓ Health endpoint (/health)... "
if curl -sf http://localhost:3000/health > /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    kill $SERVER_PID
    exit 1
fi

echo -n "  ✓ HTML endpoint (/html)... "
if curl -sf http://localhost:3000/html > /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    kill $SERVER_PID
    exit 1
fi

# Stop server
kill $SERVER_PID
echo ""
echo -e "${GREEN}✅ Local tests passed!${NC}"
echo ""

# =============================================================================
# Step 2: Test Docker Build
# =============================================================================
echo -e "${YELLOW}🐳 Step 2: Testing Docker Build${NC}"
echo ""

echo "Building Docker image..."
docker build -t ${IMAGE_NAME}:test .

echo "Running Docker container..."
docker run -d --name demo-test -p 3001:3000 ${IMAGE_NAME}:test

# Wait for container to start
sleep 5

# Test container
echo ""
echo -e "${GREEN}Testing Docker container:${NC}"

echo -n "  ✓ Container health... "
if curl -sf http://localhost:3001/health > /dev/null; then
    echo -e "${GREEN}OK${NC}"
else
    echo -e "${RED}FAILED${NC}"
    docker stop demo-test
    docker rm demo-test
    exit 1
fi

# Cleanup
docker stop demo-test
docker rm demo-test
docker rmi ${IMAGE_NAME}:test

echo ""
echo -e "${GREEN}✅ Docker tests passed!${NC}"
echo ""

# =============================================================================
# Step 3: GitHub Setup Instructions
# =============================================================================
echo -e "${YELLOW}📋 Step 3: GitHub Setup${NC}"
echo ""

echo "To deploy to production, you need to:"
echo ""
echo "1. Create a GitHub repository (if not already created)"
echo "2. Add GitHub Secrets (Repository → Settings → Secrets):"
echo "   - REGISTRY_USER"
echo "   - REGISTRY_PASSWORD"
echo "   - PRODUCTION_HOST"
echo "   - PRODUCTION_USER"
echo "   - PRODUCTION_SSH_KEY"
echo ""
echo "3. Initialize git and push to GitHub:"
echo ""
echo "   cd $DEMO_DIR"
echo "   git init"
echo "   git add ."
echo "   git commit -m 'Initial commit: Hello World demo app'"
echo "   git branch -M main"
echo "   git remote add origin <your-github-repo-url>"
echo "   git push -u origin main"
echo ""

read -p "Have you completed GitHub setup? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Please complete GitHub setup first.${NC}"
    echo "See: $DEMO_DIR/../infrastructure/GITHUB-CONFIG.md"
    exit 0
fi

# =============================================================================
# Step 4: Prepare Production Server
# =============================================================================
echo ""
echo -e "${YELLOW}🚀 Step 4: Preparing Production Server${NC}"
echo ""

echo "Preparing production server at ${PRODUCTION_HOST}..."

ssh ${PRODUCTION_USER}@${PRODUCTION_HOST} << EOF
    set -e
    
    # Create deployment directory
    sudo mkdir -p ${DEPLOY_PATH}
    sudo chown ${PRODUCTION_USER}:${PRODUCTION_USER} ${DEPLOY_PATH}
    
    # Verify Traefik network
    docker network ls | grep traefik-public || docker network create traefik-public
    
    echo "✅ Production server ready!"
EOF

echo -e "${GREEN}✅ Production server prepared!${NC}"
echo ""

# =============================================================================
# Step 5: Deployment Instructions
# =============================================================================
echo -e "${YELLOW}📤 Step 5: Deploy to Production${NC}"
echo ""

echo "To deploy, push to GitHub:"
echo ""
echo "  cd $DEMO_DIR"
echo "  git push origin main"
echo ""
echo "Or create a version tag:"
echo ""
echo "  git tag -a v1.0.0 -m 'Release v1.0.0'"
echo "  git push origin v1.0.0"
echo ""
echo "GitHub Actions will automatically:"
echo "  1. Build multi-arch Docker image"
echo "  2. Push to registry"
echo "  3. Deploy to production"
echo "  4. Run health checks"
echo "  5. Rollback if health checks fail"
echo ""
echo "Monitor deployment:"
echo "  - GitHub: https://github.com/<your-repo>/actions"
echo "  - Production: https://samvikresearch.com"
echo ""

# =============================================================================
# Summary
# =============================================================================
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ All Tests Passed!                                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Next steps:"
echo "  1. Push to GitHub: git push origin main"
echo "  2. Watch GitHub Actions"
echo "  3. Visit: https://samvikresearch.com"
echo ""
echo "Documentation:"
echo "  - Setup Guide: ../infrastructure/GITHUB-CONFIG.md"
echo "  - Rollback Info: ../infrastructure/ROLLBACK-SUMMARY.md"
echo ""
