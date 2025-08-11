# Dockerfile for Gemini CLI OpenAI Worker (Development with Bun)

FROM oven/bun:1.0-slim

# Install security updates and required packages
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y curl wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create a non-root user for security
RUN groupadd -g 1001 bun && \
    useradd -r -u 1001 -g bun worker

# Set working directory inside the container
WORKDIR /app

# Copy package files first to leverage Docker cache
COPY package.json bun.lockb* ./

# Install project dependencies with bun
RUN bun install --frozen-lockfile

# Copy the rest of your application code
COPY . .

# Set correct ownership for the app directory
RUN chown -R worker:bun /app

# Switch to non-root user for security
USER worker

# Expose the port the worker will run on
EXPOSE 8787

# Health check to ensure the service is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:8787/health || exit 1

# Command to run the worker in development mode with hot-reloading
CMD ["bun", "--hot", "src/index.ts"]