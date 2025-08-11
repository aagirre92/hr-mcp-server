# Use the official .NET runtime as a parent image
FROM mcr.microsoft.com/dotnet/aspnet:10.0-preview AS base
WORKDIR /app
EXPOSE 8080

# Use the SDK image to build the application
FROM mcr.microsoft.com/dotnet/sdk:10.0-preview AS build
WORKDIR /src

# Copy csproj and restore as distinct layers
COPY ["hr-mcp-server.csproj", "."]
RUN dotnet restore "hr-mcp-server.csproj"

# Copy everything else and build
COPY . .
WORKDIR "/src"
RUN dotnet build "hr-mcp-server.csproj" -c Release -o /app/build

# Publish the application
FROM build AS publish
RUN dotnet publish "hr-mcp-server.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Build runtime image
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

# Create a non-root user
RUN groupadd -r appuser && useradd -r -g appuser appuser
RUN chown -R appuser:appuser /app
USER appuser

# Set environment variables for Cloud Run
ENV ASPNETCORE_URLS=http://*:8080
ENV ASPNETCORE_ENVIRONMENT=Production

ENTRYPOINT ["dotnet", "hr-mcp-server.dll"]
