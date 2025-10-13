// Load environment variables first
require('dotenv').config();

const createError = require('http-errors');
const express = require('express');
const path = require('path');
const cookieParser = require('cookie-parser');
const helmet = require('helmet');
const cors = require('cors');
const compression = require('compression');
const rateLimit = require('express-rate-limit');
const pinoHttp = require('pino-http');
const logger = require('./utils/logger');

const indexRouter = require('./routes/index');
const usersRouter = require('./routes/users');

const app = express();
const isDevelopment = process.env.NODE_ENV === 'development';

// Trust proxy - important for rate limiting and client IP detection behind reverse proxies
app.set('trust proxy', 1);

// Disable x-powered-by header for security
app.disable('x-powered-by');

// View engine setup
app.set('views', path.join(__dirname, 'views'));
app.set('view engine', 'ejs');

// Security middleware - Helmet
app.use(
  helmet({
    contentSecurityPolicy: isDevelopment ? false : undefined,
  })
);

// CORS middleware
const corsOptions = {
  origin: process.env.CORS_ORIGIN || '*',
  credentials: true,
};
app.use(cors(corsOptions));

// Compression middleware
app.use(compression());

// Pino HTTP logger middleware
app.use(
  pinoHttp({
    logger: logger,
    customLogLevel: function (req, res, err) {
      if (res.statusCode >= 400 && res.statusCode < 500) {
        return 'warn';
      } else if (res.statusCode >= 500 || err) {
        return 'error';
      }
      return 'info';
    },
    customSuccessMessage: function (req, res) {
      return `${req.method} ${req.url} completed`;
    },
    customErrorMessage: function (req, res, err) {
      return `${req.method} ${req.url} failed: ${err.message}`;
    },
  })
);

// Body parsing middleware
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cookieParser());

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Rate limiting for API routes
const apiLimiter = rateLimit({
  windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS) || 15 * 60 * 1000, // 15 minutes
  max: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS) || 100,
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});
app.use('/api', apiLimiter);

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({
    status: 'ok',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: process.env.NODE_ENV || 'development',
  });
});

// Application routes
app.use('/', indexRouter);
app.use('/users', usersRouter);

// Catch 404 and forward to error handler
app.use(function (req, res, next) {
  next(createError(404));
});

// Error handler
app.use(function (err, req, res, next) {
  // Log error with request context
  req.log.error({
    err,
    req: {
      method: req.method,
      url: req.url,
      headers: req.headers,
    },
  }, 'Request error');

  // Set locals, only providing error details in development
  res.locals.message = err.message;
  res.locals.error = isDevelopment ? err : {};

  const statusCode = err.status || 500;

  // Return JSON for API routes or if client accepts JSON
  if (req.path.startsWith('/api') || req.accepts('json')) {
    return res.status(statusCode).json({
      error: {
        message: isDevelopment ? err.message : 'An error occurred',
        status: statusCode,
        ...(isDevelopment && { stack: err.stack }),
      },
    });
  }

  // Render the error page for browser requests
  res.status(statusCode);
  res.render('error');
});

module.exports = app;
