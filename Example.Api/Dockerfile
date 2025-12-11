FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build-env
WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . .
RUN dotnet publish -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=build-env /app/out ./

ENV DOTNET_URLS=http://+:80
EXPOSE 80

ENTRYPOINT ["dotnet", "Example.Api.dll"]

# docker build -t example-api .
# docker run -d -p 8080:80 --name example-api example-api

# docker buildx create --use --name multi-arch
# docker buildx build --platform linux/amd64,linux/arm64 --push -t joechandler73/example-api .
# docker buildx rm multi-arch