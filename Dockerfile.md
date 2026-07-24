# 🔹 Runtime
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app

# 🔥 INSTALA DEPENDÊNCIAS NECESSÁRIAS DO POSTGRES
RUN apt-get update && apt-get install -y \
    libkrb5-3 \
    libgssapi-krb5-2 \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# 🔹 Build
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY . .

RUN dotnet restore "src/Api/Desenvolvimento.Api.csproj"
RUN dotnet build "src/Api/Desenvolvimento.Api.csproj" -c Release -o /app/build

# 🔹 Publish
FROM build AS publish
RUN dotnet publish "src/Api/Desenvolvimento.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# 🔹 Final
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .

ENTRYPOINT ["dotnet", "Desenvolvimento.Api.dll"]