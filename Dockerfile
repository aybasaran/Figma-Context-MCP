FROM node:20-alpine AS base

# Set working directory
WORKDIR /app

# Use pnpm as the package manager
RUN corepack enable && corepack prepare pnpm@latest --activate

# Install dependencies
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile

# Copy source files
COPY . .

# Build the application
RUN pnpm build

# Create a smaller production image
FROM node:20-alpine AS production

WORKDIR /app

# Copy only the necessary files from the build stage
COPY --from=base /app/dist ./dist
COPY --from=base /app/package.json ./
COPY --from=base /app/pnpm-lock.yaml ./

# Install only production dependencies
RUN corepack enable && corepack prepare pnpm@latest --activate && \
  pnpm install --prod --frozen-lockfile

# Set environment variables
ENV NODE_ENV=production
ENV PORT=3333

# Expose the port the app runs on
EXPOSE 3333

# Command to run the application
CMD ["node", "dist/cli.js"]
