# Hello World Demo App

Express.js demo application for testing CI/CD pipeline with automatic deployment and rollback.

## 🚀 Features

- ✅ Express.js server
- ✅ Health check endpoint (`/health`)
- ✅ JSON API endpoint (`/`)
- ✅ HTML endpoint (`/html`)
- ✅ Multi-architecture Docker support (ARM64 + AMD64)
- ✅ Production-ready Dockerfile
- ✅ Automatic deployment via GitHub Actions
- ✅ Automatic rollback on failure

## 📋 Endpoints

| Endpoint | Description |
|----------|-------------|
| `/` | JSON response with server info |
| `/health` | Health check (returns 200 OK) |
| `/html` | HTML page with server info |

## 🏃 Run Locally

```bash
# Install dependencies
npm install

# Start server
npm start

# Test endpoints
curl http://localhost:3000/
curl http://localhost:3000/health
```

## 🐳 Docker

```bash
# Build image
docker build -t demo-app .

# Run container
docker run -p 3000:3000 demo-app

# Test
curl http://localhost:3000/health
```

## 🚀 Deploy to Production

Just push to GitHub:

```bash
git add .
git commit -m "feat: update demo app"
git push origin main
```

The CI/CD pipeline will:
1. Build multi-arch Docker image
2. Push to private registry
3. Deploy to production
4. Run health checks
5. Rollback automatically if health checks fail

## 🌐 Production URL

After deployment: `https://demo.jsoftsolutions.in`

## 🔄 Automatic Rollback

If deployment fails (e.g., health check fails), the system automatically rolls back to the previous version in ~20 seconds.

## 🧪 Test Rollback

To test automatic rollback, break the health endpoint:

```javascript
// Comment out the health endpoint in server.js
// app.get('/health', (req, res) => { ... });
```

Then push to GitHub. The deployment will fail and automatically rollback.
