# Referencia de API REST y WebSockets — SmartCase

Esta guía documenta los endpoints expuestos por el servidor backend escrito en **Go (Gin Framework)**.

---

## Autenticación Pública (`/api`)

### `POST /api/login`
Inicia sesión y genera el token de sesión o JWT.

- **Request Body**:
  ```json
  {
    "email": "conductor@hospital.org",
    "password": "mi_password_segura"
  }
  ```
- **Response `200 OK`**:
  ```json
  {
    "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "usuario": {
      "id_usuario": "a1b2c3d4-...",
      "nombre_completo": "Carlos Pérez",
      "rol": "coductor",
      "email": "conductor@hospital.org"
    }
  }
  ```

### `POST /api/register`
Registra un nuevo usuario en la plataforma.

---

##  Zona de Administración (`/api/app/panel-admin`)
*Requiere cabecera `Authorization` o sesión activa con rol `admin`.*

### Gestión de Clínicas y Sedes
- `POST /api/app/panel-admin/clinica/crear`: Crear una nueva clínica.
- `GET /api/app/panel-admin/clinica/lista`: Obtener listado de clínicas.
- `GET /api/app/panel-admin/clinica/obtener`: Consultar datos de una clínica por ID.
- `PUT /api/app/panel-admin/clinica/actualizar`: Actualizar información institucional.
- `DELETE /api/app/panel-admin/clinica/borrar`: Eliminar clínica.
- `POST /api/app/panel-admin/clinica/sede/crear`: Registrar una nueva sede.
- `GET /api/app/panel-admin/clinica/sede/lista`: Listar sedes asociadas.

### Gestión de Ambulancias y SmartCases
- `POST /api/app/panel-admin/ambulancia/crear`: Registrar ambulancia o motocicleta.
- `GET /api/app/panel-admin/ambulancia/lista`: Listar vehículos activos.
- `POST /api/app/panel-admin/smartcase/crear`: Registrar nuevo contenedor térmico.
- `GET /api/app/panel-admin/smartcase/lista`: Listar neveras disponibles.

### Gestión de Viajes y Telemetría
- `POST /api/app/panel-admin/viaje/crear`: Iniciar un nuevo viaje de transporte biológico.
- `GET /api/app/panel-admin/viaje/viajes-estado`: Obtener viajes filtrados por estado.
- `GET /api/app/panel-admin/viaje/telemetria`: Obtener trazabilidad histórica de un viaje.
- `GET /api/app/panel-admin/viaje/tareas-viaje-telemetria`: **Canal WebSocket** para transmisión de telemetría en tiempo real.

---

## Zona de Conductores (`/api/app/conductor`)
*Requiere rol `coductor`.*

- `GET /api/app/conductor/viaje/tareas-viaje`: Listar viajes asignados al conductor.
- `PUT /api/app/conductor/viaje/actualizar-estado-viaje`: Cambiar estado del viaje (`transito`, `entregado`, `muestra comprometida`).
- `POST /api/app/conductor/viaje/pin-desbloqueo`: Validar PIN de 6 dígitos para solicitar la apertura electromagnética de la nevera.
  - **Request Body**:
    ```json
    {
      "id_viaje": "9395a38d-e4f5-4578-bfc3-da32b0e56c9b",
      "pin": "123456",
      "latitud": 7.1193,
      "longitud": -73.1227
    }
    ```

---

## Zona de Medicos / Receptores (`/api/app/medico`)
*Requiere rol `receptor`.*

- `GET /api/app/medico/viaje/tareas-viaje`: Consultar paquetes biológicos programados hacia su sede.
- `GET /api/app/medico/viaje/telemetria`: Ver historial de temperatura, luz e impactos del transporte.

---

## ⚡ Conexión por WebSockets

- **URL**: `ws://localhost:8080/api/app/panel-admin/viaje/tareas-viaje-telemetria`
- **Protocolo**: Transmisión bidireccional JSON con actualización automática de posición GPS y lecturas de sensores.
