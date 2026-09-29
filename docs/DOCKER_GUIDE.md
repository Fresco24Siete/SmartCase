# Guía de Docker y Orquestación — SmartCase

Esta guía explica cómo ejecutar, construir y mantener el stack de **SmartCase** utilizando **Docker** y **Docker Compose**.

---

## Inicio Rápido con Docker Compose

La forma más sencilla de levantar el ecosistema completo (Base de datos + API Backend + Frontend Web) es usando `docker-compose.yml`.

### Requisitos
- **Docker Engine**: v24.0+
- **Docker Compose**: v2.20+

### Comando de Arranque
```bash
docker compose up --build -d
```

### Verificación de Contenedores
```bash
docker compose ps
```

| Nombre del Contenedor | Servicio | Puerto Expuesto | Descripción |
| :--- | :--- | :--- | :--- |
| `smartcase-db` | PostgreSQL 16 | `5432:5432` | Base de datos con `pgcrypto` y tablas automáticas |
| `smartcase-backend` | Go REST API | `8080:8080` | Servidor backend compilado en Alpine Linux |
| `smartcase-frontend` | Flutter Web SPA | `3000:80` | Aplicación Web servida por Nginx |

---

## Dockerfiles del Proyecto

### 1. Backend (`backend/Dockerfile`)
Utiliza una estrategia de compilación multi-etapa (*multi-stage build*):
1. **Stage Builder**: Utiliza `golang:alpine` para descargar dependencias e invocar `go build` con opciones de optimización (`-ldflags="-w -s"`).
2. **Stage Final**: Utiliza `alpine:3.19` incluyendo paquetes de certificados y zonas horarias (`tzdata`), generando un contenedor final de menos de 30 MB.

### 2. Frontend (`metro_gps/Dockerfile`)
1. **Stage Builder**: Utiliza `debian:bookworm-slim` con el SDK de Flutter compilando la aplicación en modo `release` para Web (`flutter build web`).
2. **Stage Final**: Copia los archivos estáticos generados a `nginx:alpine` utilizando la configuración personalizada `nginx.conf` para el manejo de rutas SPA.

---

##  Comandos Útiles de Administración

### Ver logs en tiempo real:
```bash
docker compose logs -f
```

### Reiniciar un servicio específico:
```bash
docker compose restart backend
```

### Detener y eliminar volúmenes:
```bash
docker compose down -v
```
