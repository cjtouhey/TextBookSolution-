# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

RUN apt-get update && apt-get install -y python3 && rm -rf /var/lib/apt/lists/*
COPY . .
RUN dotnet workload install wasm-tools
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output

# Serve Stage using lightweight Nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy published files
COPY --from=build /output/wwwroot .

# Fix MIME types for JavaScript modules
RUN sed -i 's/types {/types {\n    application\/javascript mjs;\n    application\/javascript js;/g' /etc/nginx/mime.types

# Add Nginx routing fallback for Blazor SPA
RUN echo 'server { \
    listen 80; \
    location / { \
        root /usr/share/nginx/html; \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80
