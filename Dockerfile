# Build Stage
FROM node:22-alpine3.21 AS builder

WORKDIR /app

COPY package*.json ./
COPY tsconfig.json ./
COPY .eslintrc ./
COPY .prettierrc ./
COPY .env ./
COPY src ./src

RUN npm install
RUN npm run build

# Production Stage
FROM node:22-alpine3.21 AS production

WORKDIR /app

COPY --from=builder /app/package*.json ./
COPY --from=builder /app/dist ./dist

RUN npm ci --only=production

# Create a non-root user
RUN addgroup -g 1001 -S nodejs
RUN adduser -S nodejs -u 1001
USER nodejs

EXPOSE 3000

CMD ["node", "dist/server.js"]
