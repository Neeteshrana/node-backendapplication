# ---------- Stage 1 ----------
FROM node:18-alpine AS builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

# ---------- Stage 2 ----------
FROM node:18-alpine
WORKDIR /app
COPY --from=builder /app ./
RUN npm prune --production
ENV NODE_ENV=production
ENV PORT=3000
RUN addgroup -S appgroup && adduser -S appuser -G appgroup
USER appuser
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
  CMD wget --no-verbose --tries=1 --spider http://localhost:3000/health || exit 1
EXPOSE 3000
CMD ["node", "index.js"]
