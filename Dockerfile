# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src
COPY . .
# Ensure static web assets from packages are bundled correctly
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output

# Serve Stage using lightweight Nginx with proper MIME types & SPA routing fallback
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy published Blazor WASM wwwroot files (includes bundled package assets)
COPY --from=build /output/wwwroot .

# Explicitly add .mjs MIME type mapping to Nginx config so PDF.js worker loads successfully
RUN sed -i 's/types {/types {\n    application\/javascript mjs;/g' /etc/nginx/mime.types

# Add a basic Nginx config to handle Blazor client-side routing (redirect missing routes to index.html)
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
