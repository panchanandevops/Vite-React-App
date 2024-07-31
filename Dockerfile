

FROM node:22-bullseye-slim AS build

# Specify working directory other than /
WORKDIR /usr/src/app

# Copy only files required to install
# dependencies (better layer caching)
COPY package*.json ./

# RUN npm install

# Use cache mount to speed up install of existing dependencies
RUN --mount=type=cache,target=/usr/src/app/.npm \
  npm set cache /usr/src/app/.npm && \
  npm ci



COPY . .

# Build the TypeScript project and the application
RUN  npm run build

# Use separate stage for deployable image
FROM nginxinc/nginx-unprivileged:alpine3.19-perl


COPY --from=build /usr/src/app/dist/ /usr/share/nginx/html

# Copying our nginx.conf
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

# Run Nginx in the foreground
CMD ["nginx", "-g", "daemon off;"]