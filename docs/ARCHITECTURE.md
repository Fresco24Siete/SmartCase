# Arquitectura de Software — SmartCase

Este documento describe la arquitectura detallada de **SmartCase** utilizando el estándar **Modelo C4** y el **Modelo de Vistas 4+1**.

---

## Modelo C4

El Modelo C4 permite abstraer y visualizar la arquitectura del sistema en diferentes niveles de profundidad.

### Nivel 1: Diagrama de Contexto del Sistema (System Context)

Muestra los actores que interactúan con el sistema y los límites del dominio:

```mermaid
graph TD
    user_admin["Administrador Hospitalario<br/>Gestión de Sedes, Neveras y Usuarios"]
    user_driver["Conductor de Ambulancia / Moto<br/>Transporte y Desbloqueo PIN"]
    user_doctor["Médico / Receptor en Sede<br/>Recepción y Auditoría de Muestra"]

    subgraph SmartCaseSystem ["SmartCase System"]
        smartcase_system["Sistema SmartCase<br/>Monitoreo Térmico y Telemetría"]
    end

    esp32_device["Contenedor IoT SmartCase (ESP32)<br/>Sensores Temp/Lux/Acelerómetro/GPS"]
    postgres_db[("PostgreSQL / Neon DB<br/>Persistencia de Telemetría")]

    user_admin -->|Monitorea flota y configura viajes| smartcase_system
    user_driver -->|Recibe trayecto e ingresa PIN| smartcase_system
    user_doctor -->|Verifica estado térmico de llegada| smartcase_system
    esp32_device -->|Envía telemetría en tiempo real| smartcase_system
    smartcase_system <-->|Lee y almacena datos| postgres_db
```

---

### Nivel 2: Diagrama de Contenedores (Container Diagram)

Identifica las aplicaciones ejecutables y los almacenes de datos:

```mermaid
graph TB
    subgraph HardwareLayer ["Hardware IoT Layer"]
        esp32["ESP32 Microcontroller<br/>Sensores + Solenoide + GPS"]
    end

    subgraph ClientApps ["Client Apps (Flutter)"]
        flutter_app["Metro GPS Client App<br/>Flutter Android / Web / Desktop"]
    end

    subgraph BackendLayer ["Backend Layer (Go API)"]
        go_api["Go REST API Server<br/>Gin Framework"]
        ws_hub["⚡ WebSockets Hub<br/>Transmisión Live Telemetría"]
    end

    subgraph StorageLayer ["Storage Layer"]
        db[("PostgreSQL 16<br/>Relacional + pgcrypto")]
    end

    esp32 -->|HTTP POST Telemetría / Bluetooth| go_api
    flutter_app -->|REST API / HTTP JSON| go_api
    flutter_app <-->|WebSocket Stream / JSON| ws_hub
    go_api -->|sqlx / pgx driver| db
    ws_hub -->|Consulta histórica| db
```

---

### Nivel 3: Diagrama de Componentes del Backend (Component Diagram)

Muestra la descomposición interna del servidor Go en paquetes desacoplados (*Clean Architecture*):

```mermaid
graph TD
    subgraph RouterGroup ["Router & Middlewares"]
        gin_router["Gin Engine Router"]
        auth_mid["Auth Middleware (JWT/RBAC)"]
    end

    subgraph HandlersGroup ["Handlers Layer"]
        auth_h["AuthHandler"]
        viaje_h["ViajeHandler"]
        tele_h["TelemetriaHandler"]
        ws_h["WsHandler"]
    end

    subgraph ServiceGroup ["Service Layer"]
        usuario_s["UsuarioService"]
        viaje_s["ViajeService"]
        smart_s["SmartService"]
    end

    subgraph RepoGroup ["Repository Layer"]
        usuario_r["UsuarioRepository"]
        viaje_r["ViajeCaseRepository"]
        tele_r["TelemetriaRepository"]
    end

    gin_router --> auth_mid
    auth_mid --> auth_h
    auth_mid --> viaje_h
    auth_mid --> tele_h
    viaje_h --> viaje_s
    auth_h --> usuario_s
    ws_h <--> ws_hub["WebSockets Hub"]
    viaje_s --> viaje_r
    tele_h --> tele_r
    usuario_s --> usuario_r
    usuario_r --> DB[("PostgreSQL")]
    viaje_r --> DB
    tele_r --> DB
```

---

## Modelo de Vistas 4+1

El modelo 4+1 complementa la vista estática con aspectos dinámicos, físicos y de desarrollo.

```mermaid
graph LR
    UC["+1 Vista de Casos de Uso<br/>Scenarios"]
    LV["1. Vista Lógica<br/>Logical View"]
    PV["2. Vista de Procesos<br/>Process View"]
    DV["3. Vista de Desarrollo<br/>Development View"]
    PHY["4. Vista Física<br/>Deployment View"]

    UC --> LV
    UC --> PV
    UC --> DV
    UC --> PHY
```

### 1. Vista Lógica (Logical View)
Define el modelo de dominio e interconexiones de datos:
- **Clínica & Sede**: Entidades institucionales que agrupan sedes de origen y destino.
- **Usuario**: Roles con permisos restringidos (`admin`, `coductor`, `receptor`).
- **SmartCase**: Entidad física del contenedor térmico y estado de solenoide (`bloqueado`, `desbloqueado`).
- **Ambulancia**: Vehículo logístico asociado al trayecto (`moto` o `ambulancia`).
- **Viaje**: Objeto raíz de la sesión logística con trazabilidad, geovalla y PIN de seguridad.
- **Telemetría**: Puntos periódicos de lectura ambiental, física y geográfica.

### 2. Vista de Procesos (Process View)
Representa los flujos de ejecución concurrentes:
- **Transmisión de Telemetría**: El dispositivo ESP32 o el puente móvil emiten un payload JSON periódicamente. El servidor Go procesa el registro en base de datos y difunde concurrentemente a través del `WebSockets Hub` a todas las pantallas cliente conectadas.
- **Validación de Geocerca y Desbloqueo por PIN**:
  1. El conductor arriba a la sede receptora.
  2. La aplicación verifica si las coordenadas GPS actuales se encuentran dentro del radio de tolerancia de la sede destino.
  3. Al ingresar el PIN de 6 dígitos suministrado al receptor, el backend valida la correspondencia y emite la instrucción de desenganche del solenoide.

### 3. Vista de Desarrollo (Development View)
Organización del proyecto en módulos y paquetes:
- **`backend/`**: Proyecto escrito en Go estructurado en `cmd/api`, `internal/` (`handlers`, `models`, `repository`, `service`, `websockets`) y `pkg/database`.
- **`metro_gps/`**: Proyecto Flutter estructurado en módulos funcionales (`auth`, `admin`, `conductor`, `receptor`, `core`).
- **`ESP32/`**: Código C++ para la programación de firmware en microcontroladores.

### 4. Vista Física / Despliegue (Physical View)
- **Nodo IoT**: ESP32 WROOM-32U con sensores (DS18B20, MPU6050, NEO-6M), celda Peltier y actuador electromagnético.
- **Servidor API**: Contenedor Docker ligero (*Alpine Linux*) ejecutando el ejecutable compilado en Go.
- **Servidor Frontend**: Contenedor Nginx sirviendo la aplicación SPA Flutter Web en puerto `3000`.
- **Base de Datos**: PostgreSQL 16 con extensión `pgcrypto` para generación de claves UUID v4.

### +1 Vista de Escenarios / Casos de Uso
1. **Inicio de Transporte Biológico**: Creación del viaje desde el panel administrativo asignando conductor, sede origen, sede destino y SmartCase.
2. **Alertas en Tiempo Real**: Notificación inmediata si la temperatura excede los 8°C o se detecta un choque superior a 2.0g.
3. **Entrega y Cadena de Custodia**: Verificación de historial térmico por parte del médico receptor e ingreso de PIN para recepción física.
