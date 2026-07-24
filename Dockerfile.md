# Etapa de Runtime
FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080

# Etapa de Build
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Copia todo o código-fonte da aplicação para o container
COPY . .

# Restaura dependências e compila a API
RUN dotnet restore "src/Api/Desenvolvimento.Api.csproj"
RUN dotnet build "src/Api/Desenvolvimento.Api.csproj" -c Release -o /app/build

# Etapa de Publicação
FROM build AS publish
RUN dotnet publish "src/Api/Desenvolvimento.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

# Etapa Final (Execução)
FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "Desenvolvimento.Api.dll"]