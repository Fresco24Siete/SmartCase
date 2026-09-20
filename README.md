# SmartCase — Monitoreo IoT y Cadena de Custodia para Muestras Biológicas

[![Go Version](https://img.shields.io/badge/Go-1.22%2B-00ADD8?style=flat&logo=go)](https://go.dev/)
[![Flutter](https://img.shields.io/badge/Flutter-3.22%2B-02569B?style=flat&logo=flutter)](https://flutter.dev/)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?style=flat&logo=docker)](https://www.docker.com/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16-4169E1?style=flat&logo=postgresql)](https://www.postgresql.org/)

**SmartCase** es un sistema integral basado en **Internet de las Cosas (IoT)**, backend distribuido en **Go** y aplicación cliente multiplataforma en **Flutter**, diseñado para garantizar la integridad térmica, la detección de impactos físicos y el control de acceso mediante geocercas en el transporte hospitalario de muestras biológicas críticas (sangre, sueros, tejidos u órganos).

El proyecto resuelve la problemática de "puntos ciegos" en la fase preanalítica de transporte intrahospitalario e intersede, reemplazando las neveras pasivas tradicionales por contenedores inteligentes con control activo de temperatura, monitoreo continuo de telemetría y cerradura solenoide automatizada.

---

## Vista General de la Interfaz

| Panel de Monitoreo General (Web) | Aplicación Móvil del Conductor |
| :---: | :---: |
| ![Dashboard de Monitoreo GPS y Telemetría](docs/images/dashboard_map.jpg) | ![App Móvil del Conductor con Desbloqueo por PIN](docs/images/conductor_app.jpg) |

### Panel Administrativo y Gestión de Trayectos
![Panel de Administración General](docs/images/admin_panel.jpg)

---

## Inicio Rápido en 1 Comando

Puedes levantar todo el ecosistema (**PostgreSQL + API Go + Frontend Web Nginx**) ejecutando:

```bash
docker compose up --build -d
```

Una vez iniciados los contenedores:
- **Frontend Web**: [http://localhost:3000](http://localhost:3000)
- **Backend REST API**: [http://localhost:8080/api](http://localhost:8080/api)
- **Base de Datos PostgreSQL**: `localhost:5432`

---

## Índice de Documentación Técnica

Para evitar un documento demasiado extenso, la información detallada del proyecto se encuentra organizada en los siguientes módulos:

| Documento | Descripción |
| :--- | :--- |
| **[Arquitectura y Modelo C4](docs/ARCHITECTURE.md)** | Diagramas C4 (Contexto, Contenedores, Componentes) y Modelo de Vistas 4+1 |
| **[Hardware IoT y Base de Datos](docs/HARDWARE_DATABASE.md)** | Componentes electrónicos ESP32, sensores (DS18B20, MPU6050, GPS) y esquema SQL |
| **[Referencia de API REST y WebSockets](docs/API_REFERENCE.md)** | Endpoints HTTP de autenticación, zonas admin, conductor, médico y canal WebSocket |
| **[Guía de Docker y Despliegue](docs/DOCKER_GUIDE.md)** | Explicación de Dockerfiles multi-etapa y administración de contenedores |
| **[Guía de Contribución](CONTRIBUTING.md)** | Flujo de trabajo en Git, estándares de código y convenciones de commits |

---

## Resumen de Arquitectura

- **Hardware Node (ESP32)**: Adquiere métricas de sensores (temperatura, acelerometría de golpe, posicionamiento GPS, luz) y controla el enfriamiento Peltier y el solenoide electromagnético.
- **Backend API (Go)**: Diseñado en capas (*Clean Architecture*) con `Gin Framework`, `sqlx` y un servidor de `WebSockets` para transmisión concurrente de telemetría.
- **Frontend App (Flutter)**: Cliente multiplataforma (Android y Web SPA) con paneles adaptados a los roles de Administrador, Conductor y Médico Receptor.
- **Storage (PostgreSQL 16)**: Persistencia relacional optimizada con claves UUID v4 nativas.

---

## Licencia

Este proyecto está licenciado bajo los términos de la licencia **MIT**. Consulta el archivo `LICENSE` para más información.
