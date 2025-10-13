# Demo Express.js Application

A production-ready Express.js application featuring PM2 cluster mode, structured logging, security middleware, and comprehensive monitoring capabilities.

## Features

- **Express.js Framework** - Fast, unopinionated, minimalist web framework
- **PM2 Cluster Mode** - Multi-process load balancing across all CPU cores
- **Structured Logging** - Pino logger with pretty-printing in development, JSON in production
- **Security Middleware** - Helmet for security headers, CORS support, rate limiting
- **Performance Optimization** - Response compression, optimized middleware stack
- **Health Monitoring** - Health check endpoint with uptime and environment info
- **Environment Configuration** - dotenv for environment variable management
- **Development Tools** - Nodemon for hot-reloading during development

## Architecture Overview

### Middleware Stack

The application uses a carefully ordered middleware stack:

1. **dotenv** - Loads environment variables
2. **Helmet** - Security headers (CSP disabled in development)
3. **CORS** - Cross-Origin Resource Sharing support
4. **Compression** - Gzip/deflate response compression
5. **Pino-HTTP** - Structured request/response logging
6. **Body Parsers** - JSON and URL-encoded body parsing
7. **Cookie Parser** - Cookie parsing middleware
8. **Static Files** - Serves files from public/ directory
9. **Rate Limiting** - Applied to /api/* routes
10. **Application Routes** - Custom route handlers
11. **Error Handler** - Comprehensive error handling with logging

### Logging System

- **Development**: Pretty-printed, colorized logs with pino-pretty
- **Production**: Structured JSON logs for aggregation and analysis
- **Request Logging**: Automatic HTTP request/response logging
- **Error Context**: Errors logged with full request context

### PM2 Clustering

- **Cluster Mode**: Spawns one process per CPU core
- **Load Balancing**: Built-in round-robin load balancing
- **Auto-Restart**: Automatic restart on crash or memory limit
- **Graceful Shutdown**: 5-second grace period for in-flight requests
- **Log Management**: Centralized log files in logs/ directory

## Prerequisites

- **Node.js**: v16.x or higher recommended
- **npm**: v7.x or higher
- **PM2**: Install globally with `npm install -g pm2` (for production)

## Installation

1. Clone the repository:
```bash
git clone git@github.com:NIXKnight/demo_express_js_app.git
cd demo_express_js_app
```

2. Install dependencies:
```bash
npm install
```

3. Configure environment variables:
```bash
cp .env.example .env
# Edit .env with your configuration
```

## Development

### Start Development Server

Hot-reload development server with pretty logs:

```bash
npm run dev
```

The server will start on port 3000 (or PORT from .env) and automatically restart on file changes.

### PM2 Commands

Start with PM2 in cluster mode:
```bash
npm run pm2:start
```

View PM2 status:
```bash
npm run pm2:status
```

View logs:
```bash
npm run pm2:logs
```

Monitor in real-time:
```bash
npm run pm2:monit
```

Restart application:
```bash
npm run pm2:restart
```

Stop application:
```bash
npm run pm2:stop
```

Remove from PM2:
```bash
npm run pm2:delete
```

## Environment Variables

Create a `.env` file in the root directory (use `.env.example` as template):

| Variable | Description | Default |
|----------|-------------|---------|
| `NODE_ENV` | Application environment (development/production) | `development` |
| `PORT` | Server port | `3000` |
| `LOG_LEVEL` | Logging level (trace/debug/info/warn/error/fatal) | `info` (prod), `debug` (dev) |
| `RATE_LIMIT_WINDOW_MS` | Rate limit window in milliseconds | `900000` (15 min) |
| `RATE_LIMIT_MAX_REQUESTS` | Max requests per window | `100` |
| `CORS_ORIGIN` | Allowed CORS origins (* for all) | `*` |

## Deployment

### Production Deployment with PM2

1. Ensure NODE_ENV is set to production:
```bash
export NODE_ENV=production
```

2. Start with PM2:
```bash
npm run pm2:start
```

3. Configure PM2 to start on system boot:
```bash
pm2 startup
pm2 save
```

4. Monitor application:
```bash
pm2 monit
```

### Production Checklist

- [ ] Set NODE_ENV=production
- [ ] Configure .env with production values
- [ ] Set appropriate CORS_ORIGIN (not *)
- [ ] Configure LOG_LEVEL to info or warn
- [ ] Set up log rotation
- [ ] Configure reverse proxy (nginx/Apache)
- [ ] Set up SSL/TLS certificates
- [ ] Configure firewall rules
- [ ] Set up monitoring and alerting

## Project Structure

```
demo_express_js_app/
├── app.js                 # Express application setup
├── bin/
│   └── www               # Server bootstrap
├── ecosystem.config.js   # PM2 configuration
├── logs/                 # PM2 logs directory
│   ├── pm2-error.log
│   └── pm2-out.log
├── package.json          # Dependencies and scripts
├── public/               # Static assets
│   ├── images/
│   ├── javascripts/
│   └── stylesheets/
├── routes/               # Route handlers
│   ├── index.js
│   └── users.js
├── utils/                # Utility modules
│   └── logger.js         # Pino logger configuration
├── views/                # EJS templates
│   ├── error.ejs
│   └── index.ejs
├── .env.example          # Environment variable template
├── .gitignore           # Git ignore patterns
└── README.md            # This file
```

## API Endpoints

### Health Check

```
GET /health
```

Returns application health status:

```json
{
  "status": "ok",
  "timestamp": "2025-10-13T19:30:00.000Z",
  "uptime": 123.456,
  "environment": "production"
}
```

### Default Routes

- `GET /` - Home page
- `GET /users` - Users route

## Security Features

### Helmet

Helmet sets various HTTP headers for security:

- Content Security Policy (disabled in development)
- X-DNS-Prefetch-Control
- X-Frame-Options
- X-Content-Type-Options
- Strict-Transport-Security
- X-Download-Options
- X-Permitted-Cross-Domain-Policies

### Rate Limiting

API routes (/api/*) are protected with rate limiting:

- Default: 100 requests per 15 minutes per IP
- Returns 429 status when limit exceeded
- Configurable via environment variables

### Additional Security

- `x-powered-by` header disabled
- Trust proxy enabled for proper IP detection
- Cookie parsing with security considerations
- CORS configurable per environment

## Performance Considerations

### Clustering

PM2 cluster mode provides:

- **Horizontal Scaling**: Multiple processes handle requests
- **Load Distribution**: Built-in round-robin load balancing
- **CPU Utilization**: Uses all available CPU cores
- **Zero Downtime**: Rolling restarts with pm2 reload

### Compression

Response compression reduces bandwidth:

- Gzip/deflate compression for text responses
- Automatic content negotiation
- Threshold-based compression

### Memory Management

- Memory limit: 1GB per process (configurable in ecosystem.config.js)
- Auto-restart on memory threshold
- Graceful shutdown prevents memory leaks

## Troubleshooting

### Application Won't Start

1. Check Node.js version: `node --version` (requires v16+)
2. Reinstall dependencies: `rm -rf node_modules package-lock.json && npm install`
3. Check port availability: `lsof -i :3000`
4. Review logs: `npm run pm2:logs` or check logs/ directory

### PM2 Issues

1. Check PM2 status: `npm run pm2:status`
2. View detailed logs: `pm2 logs demo-express-js-app --lines 100`
3. Restart application: `npm run pm2:restart`
4. Delete and restart: `npm run pm2:delete && npm run pm2:start`

### Memory Leaks

1. Monitor memory usage: `npm run pm2:monit`
2. Check for memory-intensive operations
3. Review log aggregation settings
4. Adjust max_memory_restart in ecosystem.config.js

### High CPU Usage

1. Check number of PM2 instances: `npm run pm2:status`
2. Review cluster mode configuration
3. Check for infinite loops or blocking operations
4. Use profiling tools: `node --prof ./bin/www`

### Log Issues

1. Check log directory permissions: `ls -la logs/`
2. Verify LOG_LEVEL in .env
3. Review pino configuration in utils/logger.js
4. Check disk space: `df -h`
