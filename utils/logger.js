const pino = require('pino');

const isDevelopment = process.env.NODE_ENV === 'development';

/**
 * Pino logger configuration
 * - Development: Pretty-printed, human-readable logs with colors
 * - Production: JSON-formatted logs for structured logging
 */
const logger = pino({
  level: process.env.LOG_LEVEL || (isDevelopment ? 'debug' : 'info'),
  transport: isDevelopment
    ? {
        target: 'pino-pretty',
        options: {
          colorize: true,
          translateTime: 'HH:MM:ss Z',
          ignore: 'pid,hostname',
          singleLine: false,
        },
      }
    : undefined,
  formatters: {
    level: (label) => {
      return { level: label };
    },
  },
  timestamp: pino.stdTimeFunctions.isoTime,
  base: {
    env: process.env.NODE_ENV || 'development',
    pid: process.pid,
  },
});

module.exports = logger;
