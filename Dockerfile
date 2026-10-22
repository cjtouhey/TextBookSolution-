# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src
COPY . .
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output

# Serve Stage using lightweight Nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy published Blazor WASM wwwroot files
COPY --from=build /output/wwwroot .

# Safely add .mjs MIME type to Nginx
RUN echo "    application/javascript mjs;" >> /etc/nginx/mime.types

# Add Nginx config for SPA routing fallback
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
