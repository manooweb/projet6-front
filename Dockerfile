FROM node:22-alpine AS build

# Update libcrypto3 and libssl3 to fix vulnerabilities
RUN apk upgrade --no-cache libcrypto3 libssl3
RUN npm install --global npm@12.0.2 && npm cache clean --force

WORKDIR /app

COPY package.json package-lock.json ./
RUN npm ci

COPY . .
RUN npm run build -- --configuration production

FROM nginx:stable-alpine

# Update libuuid to fix vulnerabilities
RUN apk upgrade --no-cache libuuid

COPY nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist/olympic-games-starter/browser/ /app/

USER nginx

EXPOSE 80
