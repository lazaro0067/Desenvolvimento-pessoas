FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["src/Api/Desenvolvimento.Api.csproj", "src/Api/"]
COPY ["src/Services/Desenvolvimento.Services.csproj", "src/Services/"]
COPY ["src/Core/Desenvolvimento.Core.csproj", "src/Core/"]
COPY ["src/Infrastructure/Desenvolvimento.Infrastructure.csproj", "src/Infrastructure/"]
RUN dotnet restore "src/Api/Desenvolvimento.Api.csproj"
COPY . .
WORKDIR "/src"
RUN dotnet build "src/Api/Desenvolvimento.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "src/Api/Desenvolvimento.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "Desenvolvimento.Api.dll"]
