module.exports = {
  apps: [
    {
      name: 'demo-express-js-app',
      script: './bin/www',
      instances: 'max', // Use all available CPU cores
      exec_mode: 'cluster', // Enable cluster mode for load balancing

      // Environment variables
      env: {
        NODE_ENV: 'development',
        PORT: 3000,
      },
      env_production: {
        NODE_ENV: 'production',
        PORT: 3000,
      },

      // Auto-restart configuration
      autorestart: true,
      watch: false, // Disable file watching in production
      max_memory_restart: '1G', // Restart if memory exceeds 1GB

      // Graceful shutdown
      kill_timeout: 5000, // Time to wait for graceful shutdown
      listen_timeout: 3000, // Time to wait for app to be ready
      shutdown_with_message: true,

      // Logging
      error_file: './logs/pm2-error.log',
      out_file: './logs/pm2-out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,

      // Advanced features
      min_uptime: '10s', // Minimum uptime before considering app as stable
      max_restarts: 10, // Max restart attempts within 1 minute
      restart_delay: 4000, // Delay between restarts

      // Process management
      node_args: '--max-old-space-size=2048', // Node.js memory limit

      // Source map support (optional)
      source_map_support: false,

      // Instance variables
      instance_var: 'INSTANCE_ID',
    },
  ],
};
