FROM node:alpine
WORKDIR /app

COPY . .
EXPOSE 3000

COPY package*.json ./
RUN npm install 
ENTRYPOINT npm start
