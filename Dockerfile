# Stage 1: Build the static site
FROM node:20-alpine AS builder
WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

# Eleventy source + config
COPY eleventy.config.js ./
COPY src/ src/

RUN npm run build

# Stage 2: Serve with Nginx
FROM nginx:alpine
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/static.conf /etc/nginx/conf.d/default.conf

# Eleventy output dir is `_site` (see eleventy.config.js)
COPY --from=builder /app/_site/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
