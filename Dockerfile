# Build Stage
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src
COPY . .
RUN dotnet publish "Lesson4uMaterialOrganizer.sln" -c Release -o /output

# Serve Stage using lightweight Nginx
FROM nginx:alpine
WORKDIR /usr/share/nginx/html
# Copy published Blazor WASM wwwroot files to Nginx web root
COPY --from=build /output/wwwroot .
# (Optional) If you have custom routing or client-side fallback needs, Nginx handles static files out of the box
EXPOSE 80
