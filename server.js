const express = require('express');
const path = require('path');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Serve static files from the 'public' directory
app.use(express.static(path.join(__dirname, 'public')));

// Health check endpoint (required for automatic rollback)
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    service: 'samvik-research-main'
  });
});

// Root endpoint - serves the Coming Soon page
app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Legacy /html endpoint - redirect to root or serve same page
app.get('/html', (req, res) => {
  res.redirect('/');
});

// Handle any other routes
app.get('*', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
  console.log(`🚀 Samvik Research Coming Soon Server running on port ${PORT}`);
  console.log(`📍 Environment: ${process.env.NODE_ENV || 'production'}`);
  console.log(`🏗️  Architecture: ${os.arch()}`);
  console.log(`💻 Platform: ${os.platform()}`);
  console.log(`✅ Health check: http://localhost:${PORT}/health`);
});
