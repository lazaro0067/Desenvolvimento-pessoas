FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src
COPY ["src/Api/Desenvolvimento.Api.csproj", "Api/"]
COPY ["src/Core/Desenvolvimento.Core.csproj", "Core/"]
COPY ["src/Infrastructure/Desenvolvimento.Infrastructure.csproj", "Infrastructure/"]
RUN dotnet restore "Api/Desenvolvimento.Api.csproj"
COPY src/ .
WORKDIR "/src/Api"
RUN dotnet build "Desenvolvimento.Api.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Desenvolvimento.Api.csproj" -c Release -o /app/publish

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
ENTRYPOINT ["dotnet", "Desenvolvimento.Api.dll"]
