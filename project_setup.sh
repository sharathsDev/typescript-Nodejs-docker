#!/bin/bash

# Exit on error
set -e

# Check if project name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <project_name>"
  exit 1
fi

PROJECT_NAME=$1

# Create project directory
mkdir "$PROJECT_NAME"
cd "$PROJECT_NAME"

# Initialize npm package
npm init -y

# Install core dependencies
npm install express cors helmet compression dotenv winston

# Install TypeScript and type definitions
npm install typescript ts-node @types/node @types/express @types/cors @types/compression -D

# Install development tools
npm install nodemon eslint prettier eslint-config-prettier eslint-plugin-prettier @typescript-eslint/parser @typescript-eslint/eslint-plugin jest ts-jest @types/jest supertest @types/supertest -D

# Initialize TypeScript configuration
npx tsc --init

# Overwrite tsconfig.json with the desired configuration
cat > tsconfig.json <<EOL
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "rootDir": "./src",
    "outDir": "./dist",
    "esModuleInterop": true,
    "strict": true,
    "forceConsistentCasingInFileNames": true,
    "skipLibCheck": true,
    "resolveJsonModule": true,
    "sourceMap": true,
    "baseUrl": ".",
    "paths": {
      "@/*": ["./src/*"]
    }
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "**/*.test.ts"]
}
EOL

# Create project structure
mkdir -p src/{config,controllers,middleware,models,routes,services,utils,types,logs}
touch src/{app.ts,server.ts}
touch src/config/{database.ts,environment.ts}
touch src/controllers/index.ts
touch src/middleware/{error.middleware.ts,logger.middleware.ts,validation.middleware.ts}
touch src/models/index.ts
touch src/routes/{api.routes.ts,index.ts}
touch src/services/index.ts
touch src/utils/{logger.ts,response.ts}
touch src/types/index.ts

# Create .env file
cat > .env <<EOL
NODE_ENV=development
PORT=3000
LOG_LEVEL=debug
EOL

# Create .env.example file
cat > .env.example <<EOL
NODE_ENV=
PORT=
LOG_LEVEL=
EOL

# Add environment configuration file
cat > src/config/environment.ts <<EOL
import dotenv from 'dotenv';
import path from 'path';

// Load environment variables from .env file
dotenv.config({ path: path.join(__dirname, '../../.env') });

export interface EnvironmentVariables {
  NODE_ENV: string;
  PORT: number;
  LOG_LEVEL: string;
}

export const environment: EnvironmentVariables = {
  NODE_ENV: process.env.NODE_ENV || 'development',
  PORT: parseInt(process.env.PORT || '3000', 10),
  LOG_LEVEL: process.env.LOG_LEVEL || 'info',
};

export const isDevelopment = environment.NODE_ENV === 'development';
export const isProduction = environment.NODE_ENV === 'production';
export const isTest = environment.NODE_ENV === 'test';
EOL

# Add logger utility
cat > src/utils/logger.ts <<EOL
import winston from 'winston';
import { environment, isDevelopment } from '../config/environment';

const logger = winston.createLogger({
  level: environment.LOG_LEVEL,
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DD HH:mm:ss'
    }),
    winston.format.errors({ stack: true }),
    winston.format.splat(),
    winston.format.json()
  ),
  defaultMeta: { service: 'express-api' },
  transports: [
    new winston.transports.File({ filename: 'logs/error.log', level: 'error' }),
    new winston.transports.File({ filename: 'logs/combined.log' })
  ]
});

// If we're not in production, log to the console with colors
if (isDevelopment) {
  logger.add(new winston.transports.Console({
    format: winston.format.combine(
      winston.format.colorize(),
      winston.format.simple()
    )
  }));
}

export default logger;
EOL

# Add error middleware
cat > src/middleware/error.middleware.ts <<EOL
import { Request, Response, NextFunction } from 'express';
import logger from '../utils/logger';

export interface ApiError extends Error {
  statusCode?: number;
  details?: unknown;
}

export const errorHandler = (
  err: ApiError,
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const statusCode = err.statusCode || 500;
  const message = err.message || 'Internal Server Error';

  logger.error(\`\${statusCode} - \${message}\`, {
    path: req.path,
    method: req.method,
    error: err.stack,
    details: err.details
  });

  res.status(statusCode).json({
    success: false,
    message,
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
    ...(err.details && { details: err.details })
  });
};

export const notFoundHandler = (
  req: Request,
  res: Response,
  next: NextFunction
): void => {
  const error: ApiError = new Error(\`Not Found - \${req.originalUrl}\`);
  error.statusCode = 404;
  next(error);
};
EOL

# Done
echo "Project '$PROJECT_NAME' setup complete!"
