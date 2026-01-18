const express = require('express');
const os = require('os');

const app = express();
const PORT = process.env.PORT || 3000;

// Health check endpoint (required for automatic rollback)
app.get('/health', (req, res) => {
    res.status(200).json({
        status: 'ok',
        timestamp: new Date().toISOString()
    });
});

// Root endpoint
app.get('/', (req, res) => {
    const info = {
        message: '🎉 Hello World from Express.js!',
        version: '1.0.0',
        environment: process.env.NODE_ENV || 'development',
        hostname: os.hostname(),
        platform: os.platform(),
        architecture: os.arch(),
        uptime: process.uptime(),
        timestamp: new Date().toISOString()
    };

    res.json(info);
});

// HTML version
app.get('/html', (req, res) => {
    res.send(`
    <!DOCTYPE html>
    <html>
    <head>
      <title>Hello World Demo</title>
      <style>
        body {
          font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
          max-width: 800px;
          margin: 50px auto;
          padding: 20px;
          background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
          color: white;
        }
        .container {
          background: rgba(255, 255, 255, 0.1);
          backdrop-filter: blur(10px);
          border-radius: 20px;
          padding: 40px;
          box-shadow: 0 8px 32px 0 rgba(31, 38, 135, 0.37);
        }
        h1 { font-size: 3em; margin: 0; }
        .info { margin-top: 20px; font-size: 1.2em; }
        .badge {
          display: inline-block;
          background: rgba(255, 255, 255, 0.2);
          padding: 5px 15px;
          border-radius: 20px;
          margin: 5px;
        }
      </style>
    </head>
    <body>
      <div class="container">
        <h1>🎉 Hello World! TEST CICD</h1>
        <div class="info">
          <p><strong>Express.js Demo Application</strong></p>
          <div>
            <span class="badge">Version: 1.0.0</span>
            <span class="badge">Architecture: ${os.arch()}</span>
            <span class="badge">Platform: ${os.platform()}</span>
          </div>
          <p>Hostname: ${os.hostname()}</p>
          <p>Uptime: ${Math.floor(process.uptime())} seconds</p>
          <p>Time: ${new Date().toISOString()}</p>
        </div>
      </div>
    </body>
    </html>
  `);
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`🚀 Server running on port ${PORT}`);
    console.log(`📍 Environment: ${process.env.NODE_ENV || 'development'}`);
    console.log(`🏗️  Architecture: ${os.arch()}`);
    console.log(`💻 Platform: ${os.platform()}`);
    console.log(`✅ Health check: http://localhost:${PORT}/health`);
});
