# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src
COPY . .
# Force static web assets to generate and bundle into wwwroot
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output --no-self-contained

# Serve Stage using lightweight Nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy the entire output wwwroot (which will now include package assets)
COPY --from=build /output/wwwroot .

# Explicitly add .mjs MIME type mapping to Nginx config
RUN sed -i 's/types {/types {\n    application\/javascript mjs;/g' /etc/nginx/mime.types

# Add Nginx routing fallback for Blazor SPA
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf


EXPOSE 80
