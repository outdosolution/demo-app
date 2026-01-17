# 🎯 Demo App - Quick Summary

## What I Created

A complete **Express.js Hello World** demo application ready to test your CI/CD pipeline!

---

## 📁 Files Created

```
demo-app/
├── .github/
│   └── workflows/
│       └── build-deploy.yml       # GitHub Actions workflow
├── deploy/
│   └── docker-compose.yml.template # Production deployment config
├── .dockerignore                   # Docker ignore file
├── .gitignore                      # Git ignore file
├── Dockerfile                      # Multi-stage production Dockerfile
├── package.json                    # Node.js dependencies
├── server.js                       # Express.js application
├── README.md                       # App documentation
├── TESTING-GUIDE.md               # Complete testing guide
├── test-and-deploy.sh             # Automated test script
└── cleanup.sh                      # Cleanup script
```

---

## 🚀 Quick Start

### Test Everything (Automated)

```bash
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm/demo-app
./test-and-deploy.sh
```

### Manual Testing

```bash
# 1. Test locally
npm install && npm start

# 2. Test in another terminal
curl http://localhost:3000/health

# 3. Test Docker
docker build -t demo:test .
docker run -p 3001:3000 demo:test

# 4. Setup GitHub (see TESTING-GUIDE.md)

# 5. Push to GitHub
git init
git add .
git commit -m "Initial commit"
git remote add origin <your-repo-url>
git push -u origin main
```

---

## ✅ What This Tests

1. **Local Development** ✅
   - Express.js server
   - Health check endpoint
   - JSON and HTML responses

2. **Docker Build** ✅
   - Multi-stage build
   - Production optimization
   - Health checks

3. **CI/CD Pipeline** ✅
   - GitHub Actions workflow
   - Multi-arch image build (ARM64 + AMD64)
   - Push to private registry
   - Deploy to production

4. **Automatic Rollback** ✅
   - Health check failures
   - Automatic recovery
   - Zero downtime

5. **Production Deployment** ✅
   - Traefik routing
   - HTTPS with Let's Encrypt
   - Health monitoring

---

## 🎬 Testing Flow

```
1. Test Locally
   ↓
2. Test Docker Build
   ↓
3. Setup GitHub Secrets
   ↓
4. Push to GitHub
   ↓
5. GitHub Actions Runs
   ↓
6. Deploys to Production
   ↓
7. Test at https://demo.jsoftsolutions.in
   ↓
8. Test Rollback (break health check)
   ↓
9. Verify Rollback Works
   ↓
10. Cleanup Everything
```

---

## 📋 Prerequisites

Before testing, ensure you have:

- [ ] GitHub account
- [ ] GitHub repository created
- [ ] 5 GitHub secrets configured
- [ ] SSH access to VM-2 (129.159.21.78)
- [ ] Registry credentials
- [ ] DNS configured (demo.jsoftsolutions.in → 129.159.21.78)

---

## 🔑 GitHub Secrets Needed

| Secret | Value |
|--------|-------|
| `REGISTRY_USER` | `admin` |
| `REGISTRY_PASSWORD` | Your registry password |
| `PRODUCTION_HOST` | `129.159.21.78` |
| `PRODUCTION_USER` | `ubuntu` |
| `PRODUCTION_SSH_KEY` | Your SSH private key |

---

## 🌐 Endpoints

After deployment:

| Endpoint | URL |
|----------|-----|
| **Root** | https://demo.jsoftsolutions.in/ |
| **Health** | https://demo.jsoftsolutions.in/health |
| **HTML** | https://demo.jsoftsolutions.in/html |

---

## 🧪 Test Automatic Rollback

```bash
# 1. Break the health endpoint
sed -i '8,13s/^/\/\/ /' server.js

# 2. Commit and push
git add server.js
git commit -m "test: break health check"
git push origin main

# 3. Watch GitHub Actions
# - Deployment will fail
# - Rollback will trigger automatically
# - Production stays running (old version)

# 4. Fix and redeploy
git revert HEAD
git push origin main
```

---

## 🗑️ Cleanup

When done testing:

```bash
# Run cleanup script
./cleanup.sh

# Or manually:
# 1. Remove from production
ssh ubuntu@129.159.21.78 "cd /opt/apps/demo-hello-world && docker compose down && cd / && sudo rm -rf /opt/apps/demo-hello-world"

# 2. Delete GitHub repository
# Go to Settings → Delete repository

# 3. Remove local files
cd /home/ajay/Documents/OCI\ CID\ Terrfaorm
rm -rf demo-app
```

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `TESTING-GUIDE.md` | Complete step-by-step testing guide |
| `README.md` | App documentation |
| `test-and-deploy.sh` | Automated testing script |
| `cleanup.sh` | Cleanup script |

---

## ⏱️ Expected Timeline

- **Setup**: 10 minutes
- **First deployment**: 5-10 minutes
- **Rollback test**: 5 minutes
- **Cleanup**: 2 minutes
- **Total**: ~30 minutes

---

## ✅ Success Criteria

You'll know it works when:

1. ✅ Local app runs on http://localhost:3000
2. ✅ Docker container runs successfully
3. ✅ GitHub Actions workflow completes
4. ✅ App accessible at https://demo.jsoftsolutions.in
5. ✅ Health checks pass
6. ✅ Rollback works when health check fails
7. ✅ Fixed deployment succeeds

---

## 🎉 Next Steps

1. **Read**: `TESTING-GUIDE.md` for detailed instructions
2. **Run**: `./test-and-deploy.sh` to start testing
3. **Monitor**: GitHub Actions and production server
4. **Verify**: Application works at https://demo.jsoftsolutions.in
5. **Test**: Automatic rollback
6. **Cleanup**: Run `./cleanup.sh` when done

---

## 🆘 Need Help?

- **Testing Guide**: `TESTING-GUIDE.md`
- **GitHub Setup**: `../infrastructure/GITHUB-CONFIG.md`
- **Rollback Info**: `../infrastructure/ROLLBACK-SUMMARY.md`
- **Deployment Checklist**: `../infrastructure/DEPLOYMENT-CHECKLIST.md`

---

**Ready to test? Start with `./test-and-deploy.sh` or follow `TESTING-GUIDE.md`!** 🚀
