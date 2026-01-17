#!/bin/bash

# =============================================================================
# Demo App Cleanup Script
# =============================================================================
# This script removes the demo app from:
# - Local machine
# - Docker registry
# - Production server
# - GitHub repository (manual step)
# =============================================================================

set -e

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
echo -e "${BLUE}║  Demo App Cleanup Script                                   ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${YELLOW}⚠️  WARNING: This will delete the demo app from everywhere!${NC}"
echo ""
echo "This will remove:"
echo "  - Demo app from production server"
echo "  - Docker images from registry"
echo "  - Local Docker images"
echo "  - Local demo app files (optional)"
echo ""

read -p "Are you sure you want to continue? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

# =============================================================================
# Step 1: Stop and Remove from Production
# =============================================================================
echo ""
echo -e "${YELLOW}🗑️  Step 1: Removing from Production Server${NC}"
echo ""

ssh ${PRODUCTION_USER}@${PRODUCTION_HOST} << EOF
    set -e
    
    if [ -d "${DEPLOY_PATH}" ]; then
        echo "Stopping containers..."
        cd ${DEPLOY_PATH}
        docker compose down || true
        
        echo "Removing deployment directory..."
        cd /
        sudo rm -rf ${DEPLOY_PATH}
        
        echo "Removing Docker images..."
        docker images | grep ${IMAGE_NAME} | awk '{print \$3}' | xargs -r docker rmi -f || true
        
        echo "✅ Removed from production server"
    else
        echo "⚠️  Demo app not found on production server"
    fi
EOF

echo -e "${GREEN}✅ Production cleanup complete!${NC}"

# =============================================================================
# Step 2: Remove from Docker Registry
# =============================================================================
echo ""
echo -e "${YELLOW}🗑️  Step 2: Removing from Docker Registry${NC}"
echo ""

echo "Note: Registry cleanup requires registry API access."
echo "You may need to manually delete images from the registry UI:"
echo "  https://${REGISTRY}"
echo ""
echo "Or use the registry API to delete tags."

# =============================================================================
# Step 3: Remove Local Docker Images
# =============================================================================
echo ""
echo -e "${YELLOW}🗑️  Step 3: Removing Local Docker Images${NC}"
echo ""

echo "Removing local Docker images..."
docker images | grep ${IMAGE_NAME} | awk '{print $3}' | xargs -r docker rmi -f || true
echo -e "${GREEN}✅ Local Docker images removed!${NC}"

# =============================================================================
# Step 4: Remove Local Files
# =============================================================================
echo ""
echo -e "${YELLOW}🗑️  Step 4: Removing Local Files${NC}"
echo ""

read -p "Do you want to delete local demo app files? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    DEMO_DIR="/home/ajay/Documents/OCI CID Terrfaorm/demo-app"
    
    # Remove node_modules and build artifacts
    rm -rf ${DEMO_DIR}/node_modules
    rm -f ${DEMO_DIR}/package-lock.json
    
    echo -e "${GREEN}✅ Local files cleaned!${NC}"
    echo ""
    echo "Note: Source files are kept. To completely remove:"
    echo "  rm -rf ${DEMO_DIR}"
else
    echo "Local files kept."
fi

# =============================================================================
# Step 5: GitHub Repository
# =============================================================================
echo ""
echo -e "${YELLOW}📋 Step 5: GitHub Repository${NC}"
echo ""

echo "To delete the GitHub repository:"
echo "  1. Go to: https://github.com/<your-username>/<repo-name>/settings"
echo "  2. Scroll to 'Danger Zone'"
echo "  3. Click 'Delete this repository'"
echo "  4. Follow the prompts"
echo ""
echo "Or to just remove the demo app from an existing repo:"
echo "  git rm -rf demo-app/"
echo "  git commit -m 'Remove demo app'"
echo "  git push origin main"
echo ""

# =============================================================================
# Summary
# =============================================================================
echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  ✅ Cleanup Complete!                                      ║${NC}"
echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Cleaned up:"
echo "  ✅ Production server"
echo "  ✅ Local Docker images"
echo "  ⚠️  Registry (manual cleanup needed)"
echo "  ⚠️  GitHub (manual cleanup needed)"
echo ""
echo "The demo app has been removed from production."
echo ""
