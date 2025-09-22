Here’s a guide + example Docker setup to dockerize the TodoMVC / JavaScript-ES6 (webpack) version. If you prefer a different web server (nginx, http-server, etc.) or want multi-stage build, I can adjust.

What we need to cover

From the repo, here's what the app expects:

Node.js (≥ 18.13.0) + npm (≥ 8.19.3) to build. 
GitHub

A build step: npm install then npm run build → this produces static files in dist folder. 
GitHub

Local dev mode: npm run dev runs a dev server on port 7001. 
GitHub

So our Docker container should:

Install node, copy code.

Run build to get static assets.

Serve those static assets via a server (can be simple with e.g. npm run dev or using static file server).

Example Dockerfile

Here’s a Dockerfile that uses a multi-stage build to keep the final image small, serving the built static files via a simple static file server (e.g. nginx or http-server). I’ll show with nginx:

# Stage 1: build
FROM node:18-alpine AS build

WORKDIR /app

# copy package files
COPY package*.json ./
# copy webpack config etc
COPY webpack.* ./
# copy source and other files
COPY src ./src
COPY public ./public   # if there's a public folder, adjust if not
COPY . /app

RUN npm install --legacy-peer-deps
RUN npm run build

# Stage 2: serve with nginx
FROM nginx:stable-alpine

# Remove default nginx configuration
RUN rm /etc/nginx/conf.d/default.conf

# Copy a simple nginx config; you may adjust as needed
COPY nginx.conf /etc/nginx/conf.d/todomvc.conf

# Copy built files from build stage
COPY --from=build /app/dist /usr/share/nginx/html

# Expose port
EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]

Example nginx.conf

Here is a minimal nginx config for static files:

server {
    listen 80;
    server_name  localhost;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ =404;
    }
}

Alternative: using a Node based static server

If you prefer to use a node-based server instead of nginx, you could do something like:

FROM node:18-alpine

WORKDIR /app

COPY package*.json ./
COPY webpack.* ./
COPY src ./src
COPY . /app

RUN npm install --legacy-peer-deps
RUN npm run build

# install a lightweight static server globally, e.g. serve or http-server
RUN npm install -g http-server

EXPOSE 7001

CMD ["http-server", "dist", "-p", "7001"]

Steps to implement

Create Dockerfile in the javascript-es6 folder (or top‐level, adjusting paths).

Add .dockerignore to avoid copying node_modules, local build, etc.:

node_modules
dist
*.log


Build the docker image:

docker build -t todomvc-es6 .


Run it:

docker run -d -p 8080:80 todomvc-es6


(if using nginx based)
or, if using node server on port 7001, map to host: -p 8080:7001 etc.
