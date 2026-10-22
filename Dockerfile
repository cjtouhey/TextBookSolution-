# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src
COPY . .

# Install the required WebAssembly build tools workload for Blazor WASM
RUN dotnet workload install wasm-tools

# Publish the solution
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output

# Serve Stage using lightweight Nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy published Blazor WASM wwwroot files
COPY --from=build /output/wwwroot .

# Explicitly add .mjs MIME type mapping to Nginx config so PDF.js worker loads successfully
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
