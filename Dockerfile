# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src
COPY . .
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output

# Serve Stage using lightweight Nginx with proper MIME types
FROM nginx:alpine
WORKDIR /usr/share/nginx/html

# Copy published Blazor WASM wwwroot files to Nginx web root
COPY --from=build /output/wwwroot .

# Explicitly add .mjs MIME type mapping to Nginx config so PDF.js worker loads successfully
RUN sed -i 's/types {/types {\n    application\/javascript mjs;/g' /etc/nginx/mime.types

EXPOSE 80
