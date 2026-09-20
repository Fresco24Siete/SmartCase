# Hardware IoT y Base de Datos — SmartCase

Este documento detalla las especificaciones del módulo de hardware IoT basados en microcontrolador **ESP32** y el esquema de base de datos en **PostgreSQL**.

---

## Especificaciones del Hardware IoT (ESP32)

El módulo físico está integrado en un contenedor isotérmico adaptado con enfriamiento termoeléctrico y sensores multivariable.

### Componentes Electrónicos

| Componente | Función | Especificación / Modelo |
| :--- | :--- | :--- |
| **Microcontrolador** | Unidad central de procesamiento y comunicaciones | ESP32 WROOM-32U (Dual Core 240MHz, Wi-Fi / BLE) |
| **Sensor de Temperatura Interna** | Monitoreo térmico continuo en cámara biológica | DS18B20 / DHT22 (Sonda sumergible, precisión ±0.5°C) |
| **Acelerómetro / Giroscopio** | Detección de golpes, caídas y vibraciones | MPU-6050 (Acelerómetro de 3 ejes, detección de Fuerza G) |
| **Módulo GPS** | Geolocalización satelital para geovallado | NEO-6M GPS (Interface UART, antena cerámica) |
| **Sensor de Luz (Lux)** | Detección de apertura no autorizada de tapa | Fotorresistencia LDR / BH1750 |
| **Enfriamiento Activo** | Control térmico automatizado | Celda Peltier TEC1-12706 + Disipador de aluminio y ventilador 12V |
| **Cerradura Electrónica** | Bloqueo mecánico por geocerca y PIN | Solenoide electromagnético de 12V DC |

### Flujo de Funcionamiento del Firmware (`ESP32/datos.c++`)

1. **Inicialización**: Configuración de puertos seriales, pines GPIO y conexión Bluetooth/Wi-Fi.
2. **Ciclo de Lectura**: Cada intervalo programado se adquieren las lecturas de los sensores (DS18B20, MPU6050, NEO-6M).
3. **Cálculo de Impactos**: Se computa el vector de aceleración total $G = \sqrt{G_x^2 + G_y^2 + G_z^2}$. Si $G > G_{umbral}$, se marca el flag de `alerta_generada`.
4. **Envío de Payload**: Se construye la trama JSON y se transmite al backend o dispositivo móvil vía BLE/HTTP.

---

## Esquema de Base de Datos (PostgreSQL)

El esquema de persistencia relacional utiliza UUIDs v4 generados automáticamente mediante la extensión `pgcrypto`.

### Script DDL (`ESP32/bd.sql`)

```sql
-- Extensión para UUIDs automáticos
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 1. Clínica
CREATE TABLE clinica (
    id_clinica  UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    nombre      VARCHAR     NOT NULL
);

-- 2. Sede
CREATE TABLE sede (
    id_sede     UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    id_clinica  UUID        NOT NULL REFERENCES clinica(id_clinica),
    nombre      VARCHAR     NOT NULL
);

-- 3. Usuario
CREATE TABLE usuario (
    id_usuario      UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    id_sede         UUID        REFERENCES sede(id_sede),
    nombre_completo VARCHAR     NOT NULL,
    rol             VARCHAR     NOT NULL CHECK (rol IN ('coductor', 'receptor', 'admin')),
    email           VARCHAR     UNIQUE NOT NULL,
    password        VARCHAR     NOT NULL
);

-- 4. SmartCase (Caja)
CREATE TABLE smartcase (
    id_caja           UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    estado_solenoide  VARCHAR NOT NULL CHECK (estado_solenoide IN ('bloqueado', 'desbloqueado')),
    organo            VARCHAR NOT NULL
);

-- 5. Ambulancia
CREATE TABLE ambulancia (
    id_ambulancia  UUID    PRIMARY KEY DEFAULT gen_random_uuid(),
    placa          VARCHAR NOT NULL,
    tipo           VARCHAR NOT NULL CHECK (tipo IN ('moto', 'ambulancia'))
);

-- 6. Viaje
CREATE TABLE viaje (
    id_viaje              UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
    id_caja               UUID        NOT NULL REFERENCES smartcase(id_caja),
    id_usuario_conductor  UUID        NOT NULL REFERENCES usuario(id_usuario),
    id_usuario_receptor   UUID        REFERENCES usuario(id_usuario),
    id_sede_origen        UUID        NOT NULL REFERENCES sede(id_sede),
    id_sede_destino       UUID        NOT NULL REFERENCES sede(id_sede),
    id_ambulancia         UUID        NOT NULL REFERENCES ambulancia(id_ambulancia),
    fecha_inicio          TIMESTAMP   NOT NULL,
    fecha_llegada         TIMESTAMP,
    estado_viaje          VARCHAR     CHECK (estado_viaje IN ('transito', 'entregado', 'muestra comprometida')),
    pin_entrega           VARCHAR(6)  NOT NULL 
);

-- 7. Telemetría
CREATE TABLE telemetria (
    id_telemetria       UUID                     PRIMARY KEY DEFAULT gen_random_uuid(),
    id_viaje            UUID                     NOT NULL REFERENCES viaje(id_viaje),
    temperatura_interna FLOAT,
    temperatura_ambiente DECIMAL(5,2),
    humedad             DECIMAL(5,2),
    lux                 DECIMAL(10,2),
    altitud             DECIMAL(8,2),
    latitud_actual      DECIMAL                  NOT NULL,
    longitud_actual     DECIMAL                  NOT NULL,
    fuerza_g_impacto    DECIMAL,
    alerta_generada     VARCHAR,
    desde_bluetooth     BOOLEAN                  DEFAULT TRUE,
    registrado_en       TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);
```
