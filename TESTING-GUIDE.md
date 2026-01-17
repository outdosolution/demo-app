# 🧪 Demo App Test Guide

Complete guide to test the CI/CD pipeline with the Express.js Hello World demo app.

---

## 📋 Overview

This guide will walk you through:
1. ✅ Testing the app locally
2. ✅ Testing Docker build
3. ✅ Setting up GitHub
4. ✅ Deploying to production
5. ✅ Testing automatic rollback
6. ✅ Cleaning up everything

**Time required**: ~30 minutes

---

## 🚀 Quick Start (Automated)

### Option 1: Run Test Script

```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app
./test-and-deploy.sh
```

This script will:
- Install dependencies
- Test locally
- Build and test Docker image
- Guide you through GitHub setup
- Prepare production server

### Option 2: Manual Steps (see below)

---

## 📝 Manual Testing Steps

### Step 1: Test Locally

```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app

# Install dependencies
npm install

# Start server
npm start

# In another terminal, test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
curl http://localhost:3000/html

# Or open in browser
open http://localhost:3000/html
```

**Expected results:**
- ✅ Server starts on port 3000
- ✅ `/` returns JSON with server info
- ✅ `/health` returns `{"status":"ok"}`
- ✅ `/html` shows styled HTML page

---

### Step 2: Test Docker Build

```bash
# Build image
docker build -t demo-hello-world:test .

# Run container
docker run -d --name demo-test -p 3001:3000 demo-hello-world:test

# Test
curl http://localhost:3001/health
curl http://localhost:3001/

# Check logs
docker logs demo-test

# Cleanup
docker stop demo-test
docker rm demo-test
docker rmi demo-hello-world:test
```

**Expected results:**
- ✅ Image builds successfully
- ✅ Container starts without errors
- ✅ Health check returns 200 OK
- ✅ Application responds correctly

---

### Step 3: Setup GitHub Repository

#### 3.1 Create Repository

1. Go to https://github.com/new
2. Repository name: `demo-hello-world` (or your choice)
3. Visibility: Public or Private
4. **Don't** initialize with README (we have files already)
5. Click "Create repository"

#### 3.2 Add GitHub Secrets

Go to: **Repository → Settings → Secrets and variables → Actions**

Add these 5 secrets:

| Secret Name | Value | Where to Get |
|-------------|-------|--------------|
| `REGISTRY_USER` | `admin` | Your registry username |
| `REGISTRY_PASSWORD` | `[password]` | Your registry password |
| `PRODUCTION_HOST` | `129.159.21.78` | VM-2 IP |
| `PRODUCTION_USER` | `ubuntu` | SSH username |
| `PRODUCTION_SSH_KEY` | `[private-key]` | See below |

**Generate SSH Key:**

```bash
# Generate key
ssh-keygen -t ed25519 -C "github-demo" -f ~/.ssh/github_demo

# Copy public key to VM-2
ssh-copy-id -i ~/.ssh/github_demo.pub ubuntu@129.159.21.78

# Display private key (copy entire output)
cat ~/.ssh/github_demo
```

Copy the **entire private key** (including `-----BEGIN` and `-----END` lines) and add as `PRODUCTION_SSH_KEY` secret.

#### 3.3 Push to GitHub

```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app

# Initialize git
git init
git add .
git commit -m "Initial commit: Express.js Hello World demo"

# Add remote (replace with your repo URL)
git remote add origin https://github.com/YOUR_USERNAME/demo-hello-world.git

# Push
git branch -M main
git push -u origin main
```

---

### Step 4: Prepare Production Server

```bash
# SSH to VM-2
ssh ubuntu@129.159.21.78

# Create deployment directory
sudo mkdir -p /opt/apps/demo-hello-world
sudo chown ubuntu:ubuntu /opt/apps/demo-hello-world

# Verify Traefik network exists
docker network ls | grep traefik-public || docker network create traefik-public

# Verify registry login
docker login registry.jsoftsolutions.in
# Username: admin
# Password: [your-registry-password]

# Exit
exit
```

---

### Step 5: Deploy to Production

#### 5.1 Trigger Deployment

**Option A: Push to main**
```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app
git push origin main
```

**Option B: Create version tag**
```bash
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

**Option C: Manual trigger**
1. Go to GitHub → Actions tab
2. Select "Multi-Arch Build & Deploy"
3. Click "Run workflow"
4. Click "Run workflow" button

#### 5.2 Monitor Deployment

**GitHub Actions:**
1. Go to: https://github.com/YOUR_USERNAME/demo-hello-world/actions
2. Click on the running workflow
3. Watch each job:
   - ✅ Prepare Build
   - ✅ Run Tests (skipped if no tests)
   - ✅ Build Multi-Arch Image
   - ✅ Security Scan
   - ✅ Deploy to Production
   - ✅ Cleanup Old Images

**Production Server:**
```bash
# SSH to VM-2
ssh ubuntu@129.159.21.78

# Check deployment
cd /opt/apps/demo-hello-world
docker compose ps
docker compose logs -f demo-app

# Check version
cat .current_version
```

#### 5.3 Verify Deployment

```bash
# Test health endpoint
curl https://demo.jsoftsolutions.in/health

# Test main endpoint
curl https://demo.jsoftsolutions.in/

# Or open in browser
open https://demo.jsoftsolutions.in/html
```

**Expected results:**
- ✅ GitHub Actions workflow completes successfully
- ✅ Container running on production
- ✅ Health check returns 200 OK
- ✅ Application accessible via HTTPS
- ✅ Let's Encrypt certificate issued

---

### Step 6: Test Automatic Rollback

Now let's test that automatic rollback works!

#### 6.1 Break the Health Endpoint

```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app

# Edit server.js and comment out the health endpoint
# Comment lines 8-13 in server.js
```

Or use this command:
```bash
sed -i '8,13s/^/\/\/ /' server.js
```

#### 6.2 Commit and Push

```bash
git add server.js
git commit -m "test: break health check to test rollback"
git push origin main
```

#### 6.3 Watch Rollback Happen

**GitHub Actions:**
1. Go to Actions tab
2. Watch the deployment
3. You should see:
   - ✅ Build succeeds
   - ✅ Deploy starts
   - ❌ Health checks fail (5 attempts)
   - 🔄 Automatic rollback triggers
   - ✅ Previous version restored
   - ❌ Workflow marked as failed

**Expected logs:**
```
🏥 Running health checks...
Health check attempt 1/5... ❌
Health check attempt 2/5... ❌
Health check attempt 3/5... ❌
Health check attempt 4/5... ❌
Health check attempt 5/5... ❌
❌ Health checks failed after 5 attempts!
❌ Deployment failed! Rolling back...
Rolling back to: abc1234
✅ Rollback completed to version: abc1234
```

**Verify Production Still Works:**
```bash
# Should still return 200 OK (old version)
curl https://demo.jsoftsolutions.in/health
```

#### 6.4 Fix and Redeploy

```bash
# Restore the health endpoint
git revert HEAD
git push origin main
```

This should deploy successfully again!

---

### Step 7: Cleanup

When you're done testing, clean up everything:

#### 7.1 Run Cleanup Script

```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app
./cleanup.sh
```

This will:
- ✅ Stop and remove from production
- ✅ Remove Docker images
- ✅ Clean local files (optional)

#### 7.2 Delete GitHub Repository

1. Go to: https://github.com/YOUR_USERNAME/demo-hello-world/settings
2. Scroll to "Danger Zone"
3. Click "Delete this repository"
4. Type repository name to confirm
5. Click "I understand the consequences, delete this repository"

#### 7.3 Manual Cleanup (if needed)

**Remove from production:**
```bash
ssh ubuntu@129.159.21.78
cd /opt/apps/demo-hello-world
docker compose down
cd /
sudo rm -rf /opt/apps/demo-hello-world
docker images | grep demo-hello-world | awk '{print $3}' | xargs docker rmi -f
exit
```

**Remove local files:**
```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm
rm -rf demo-app
```

---

## 📊 Verification Checklist

### Local Testing
- [ ] Dependencies installed
- [ ] Server starts successfully
- [ ] All endpoints respond correctly
- [ ] Docker image builds
- [ ] Docker container runs

### GitHub Setup
- [ ] Repository created
- [ ] All 5 secrets added
- [ ] SSH key works
- [ ] Code pushed to GitHub

### Production Deployment
- [ ] Workflow runs successfully
- [ ] Multi-arch image built
- [ ] Image pushed to registry
- [ ] Deployed to production
- [ ] Health checks pass
- [ ] HTTPS certificate issued
- [ ] Application accessible

### Rollback Testing
- [ ] Broken deployment triggers rollback
- [ ] Rollback completes in ~20 seconds
- [ ] Production stays running (old version)
- [ ] Workflow marked as failed
- [ ] Fixed deployment succeeds

### Cleanup
- [ ] Removed from production
- [ ] Docker images deleted
- [ ] Local files cleaned
- [ ] GitHub repository deleted

---

## 🎯 Expected Timeline

| Step | Time |
|------|------|
| Local testing | 5 minutes |
| Docker testing | 3 minutes |
| GitHub setup | 5 minutes |
| Production prep | 2 minutes |
| First deployment | 5-10 minutes |
| Rollback test | 5 minutes |
| Cleanup | 2 minutes |
| **Total** | **~30 minutes** |

---

## 🐛 Troubleshooting

### Local Server Won't Start

**Error**: `Cannot find module 'express'`

**Fix**:
```bash
npm install
```

### Docker Build Fails

**Error**: `Cannot connect to Docker daemon`

**Fix**:
```bash
sudo systemctl start docker
```

### GitHub Actions Fails: "Permission denied"

**Error**: SSH authentication failed

**Fix**: Verify SSH key in GitHub secrets
```bash
# Test SSH key
ssh -i ~/.ssh/github_demo ubuntu@129.159.21.78
```

### Health Check Fails

**Error**: `curl: (7) Failed to connect`

**Fix**: Check if container is running
```bash
ssh ubuntu@129.159.21.78
cd /opt/apps/demo-hello-world
docker compose logs demo-app
```

### HTTPS Not Working

**Error**: `SSL certificate problem`

**Fix**: Wait for Let's Encrypt certificate (can take 1-2 minutes)
```bash
# Check Traefik logs
ssh ubuntu@129.159.21.78
docker logs traefik
```

---

## 📚 Additional Resources

- **GitHub Config**: `../infrastructure/GITHUB-CONFIG.md`
- **Rollback Guide**: `../infrastructure/ROLLBACK-SUMMARY.md`
- **Deployment Checklist**: `../infrastructure/DEPLOYMENT-CHECKLIST.md`

---

## ✅ Success Criteria

You've successfully tested the CI/CD pipeline if:

1. ✅ Local app runs and responds correctly
2. ✅ Docker image builds and runs
3. ✅ GitHub Actions workflow completes
4. ✅ App deploys to production with HTTPS
5. ✅ Automatic rollback works when deployment fails
6. ✅ Fixed deployment succeeds
7. ✅ Cleanup removes everything

**Congratulations! Your CI/CD pipeline is working perfectly!** 🎉
