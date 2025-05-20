# Use a lightweight Node.js image
FROM node:18-alpine

# Set the working directory
WORKDIR /app

# Copy package.json and package-lock.json first (for better caching)
COPY package*.json ./

# Install dependencies
RUN npm install 

# Copy the rest of the application
COPY . .

# Expose port 3000
EXPOSE 3000

# Start the app
CMD ["node", "index.js"]
