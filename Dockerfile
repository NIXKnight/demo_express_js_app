# Multi-stage Dockerfile for Express.js Application
# Optimized for both development and production environments

# ============================================
# Stage 1: Base
# ============================================
FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Create non-root user and set ownership
RUN chown -R node:node /app

# Switch to non-root user
USER node

# ============================================
# Stage 2: Dependencies (All dependencies)
# ============================================
FROM base AS dependencies

# Copy package files
COPY --chown=node:node package*.json ./

# Install all dependencies (including dev dependencies)
RUN npm ci

# ============================================
# Stage 3: Production Dependencies
# ============================================
FROM base AS production-dependencies

# Copy package files
COPY --chown=node:node package*.json ./

# Install only production dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# ============================================
# Stage 4: Development
# ============================================
FROM base AS development

# Set NODE_ENV to development
ENV NODE_ENV=development \
    LOG_LEVEL=debug

# Copy all dependencies from dependencies stage
COPY --chown=node:node --from=dependencies /app/node_modules ./node_modules

# Copy application code
COPY --chown=node:node . .

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start with nodemon for hot-reload
CMD ["npm", "run", "dev"]

# ============================================
# Stage 5: Production Build
# ============================================
FROM base AS production-build

# Copy production dependencies
COPY --chown=node:node --from=production-dependencies /app/node_modules ./node_modules

# Copy application code
COPY --chown=node:node . .

# Remove unnecessary files for production
RUN rm -rf .git .github docs tests *.md .env.example

# ============================================
# Stage 6: Production
# ============================================
FROM base AS production

# Temporarily switch to root to install PM2
USER root

# Set NODE_ENV to production
ENV NODE_ENV=production \
    LOG_LEVEL=info \
    PORT=3000

# Install PM2 globally
RUN npm install -g pm2

# Copy production dependencies and application from build stage
COPY --chown=node:node --from=production-build /app ./

# Create logs directory and set permissions
RUN mkdir -p logs && chown -R node:node logs

# Switch back to non-root user
USER node

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=15s --retries=3 \
    CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start with PM2 in cluster mode
CMD ["pm2-runtime", "start", "ecosystem.config.js", "--env", "production"]
