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
# nginx:alpine renders /etc/nginx/templates/*.template with envsubst at start (CRM_API_KEY)
RUN rm /etc/nginx/conf.d/default.conf
COPY nginx/static.conf.template /etc/nginx/templates/default.conf.template

# Eleventy output dir is `_site` (see eleventy.config.js)
COPY --from=builder /app/_site/ /usr/share/nginx/html/

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
