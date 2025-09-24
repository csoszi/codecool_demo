# Stage 1: build static assets
FROM node:18-alpine AS builder

WORKDIR /app

# copy package manifest first to leverage Docker cache
COPY package*.json ./
# if repo has package-lock.json copy it as well
COPY package-lock*.json ./

# install deps
RUN npm ci --legacy-peer-deps

# copy source files
COPY . .

# build (adjust if the project's build command differs)
RUN npm run build

# Stage 2: serve with nginx
FROM nginx:stable-alpine

# remove default config so we can provide a minimal config via image or mount
RUN rm /etc/nginx/conf.d/default.conf

# copy built assets
COPY --from=builder /app/dist /usr/share/nginx/html

# optional: provide a small nginx config that serves static files
COPY nginx.conf /etc/nginx/conf.d/todomvc.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
