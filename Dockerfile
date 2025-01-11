# Stage 1: Base image
FROM node:18 as base

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json or yarn.lock
COPY package.json yarn.lock* package-lock.json* ./

# Install dependencies
RUN npm install --legacy-peer-deps --silent \
    || yarn install --frozen-lockfile --silent

# Copy the entire monorepo
COPY . .

# Install Nx CLI globally (optional, for debugging in container)
RUN npm install -g nx

# Stage 2: Build the project
FROM base as build

# Build the monorepo (change the target as per your requirements)
RUN npx nx run-many --target=build --all

# Stage 3: Run the application
FROM node:18 as runtime

# Set the working directory
WORKDIR /app

# Copy built files from the build stage
COPY --from=build /app/dist ./dist

# Copy dependencies to avoid re-installing them
COPY package.json yarn.lock* package-lock.json* ./

# Install production dependencies only
RUN npm install --production --silent \
    || yarn install --production --silent

# Set environment variables (optional)
ENV NODE_ENV=production

# Expose the port your app listens on
EXPOSE 3000

# Default command to run your app
CMD ["node", "dist/apps/your-app-name/main.js"]
