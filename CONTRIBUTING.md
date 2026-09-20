# Guía de Contribución — SmartCase

¡Gracias por tu interés en contribuir a **SmartCase**! Este proyecto combina hardware IoT, un servidor backend distribuido y aplicaciones cliente para asegurar la cadena de custodia de muestras biológicas en entornos hospitalarios.

Para mantener una base de código limpia, escalable y mantenible, seguimos una serie de convenciones y buenas prácticas que describimos a continuación.

---

## Entorno de Desarrollo Local

Antes de empezar, asegúrate de contar con las siguientes herramientas instaladas en tu equipo:

- **Go**: v1.22 o superior.
- **Flutter SDK**: v3.22.0 o superior.
- **Docker y Docker Compose**: Para levantar el entorno multi-contenedor (PostgreSQL + Backend + Frontend Web).
- **PostgreSQL**: v16 (opcional si ejecutas la BD localmente sin Docker).
- **PlatformIO / Arduino IDE**: Si trabajas en el módulo firmware ESP32.

---

## Flujo de Trabajo con Git

Trabajamos con un esquema de ramas basado en características (`Feature Branching`).

1. **Haz un Fork o crea una rama** a partir de `main`:
   ```bash
   git checkout main
   git pull origin main
   git checkout -b feature/monitoreo-vibracion
   ```

2. **Tipos de ramas preferidos**:
   - `feature/nombre-funcionalidad`: Para nuevas características.
   - `fix/descripcion-error`: Para corrección de errores o parches.
   - `docs/nombre-documento`: Para cambios de documentación.
   - `refactor/componente-modificado`: Para refactorización de código sin cambio funcional.

---

## Convención de Commits

Adoptamos el estándar **Conventional Commits**. Cada commit debe tener un formato claro:

```text
<tipo>(<alcance opcional>): <descripción corta en presente o infinitivo>
```

### Ejemplos válidos:
- `feat(backend): agregar handler para verificación de PIN de desenganche`
- `fix(telemetria): corregir parsing de acelerometría en tramos de alta frecuencia`
- `docs(readme): añadir diagramas de arquitectura C4 y vista 4+1`
- `refactor(metro_gps): optimizar renderizado de mapa en tiempo real`
- `chore(docker): actualizar imagen base de PostgreSQL a 16-alpine`

---

## Estándares de Código

### Backend (Go)
- **Formateo obligatorio**: Ejecuta `gofmt -s -w .` y `go mod tidy` antes de confirmar cambios.
- **Manejo de Errores**: Devuelve errores explícitos. Evita usar `panic()` en controladores o repositorios.
- **Inyección de Dependencias**: Mantén desacoplada la capa de datos (`repository`), la lógica de negocio (`service`) y los controladores HTTP/WebSockets (`handlers`).

### Frontend (`metro_gps` / Flutter)
- **Análisis estático**: Pasa siempre la verificación con:
  ```bash
  flutter analyze
  ```
- **Formateo**: Aplica `dart format .` en la carpeta `metro_gps`.
- **Estructura**: Mantén la separación modular por rol/característica (`auth`, `admin`, `conductor`, `receptor`, `core`, `shared`).

### Firmware IoT (`ESP32`)
- Mantén la estructura modular para la lectura de sensores (DS18B20/DHT, MPU6050, NEO-6M GPS) y comunicación (Bluetooth / HTTP).
- Incluye comentarios descriptivos en cualquier cambio a la lógica de transmisión de payload.

---

## Pruebas y Verificación Local

Antes de abrir un Pull Request, verifica que todo el stack compila y se ejecuta correctamente:

1. **Validar compilación de Go**:
   ```bash
   cd backend
   go build ./cmd/api
   ```

2. **Validar frontend Flutter**:
   ```bash
   cd metro_gps
   flutter test
   ```

3. **Verificar contenedores Docker**:
   ```bash
   docker compose up --build -d
   ```

---

## Lista de Chequeo para Pull Requests (PR)

Al abrir un PR hacia la rama `main`, asegúrate de incluir:

- [ ] Descripción clara del problema resuelto o la funcionalidad añadida.
- [ ] Referencia al issue asociado (si aplica).
- [ ] Verificación de que el código compila localmente sin advertencias críticas.
- [ ] Commits formateados según las convenciones.
- [ ] Actualización de la documentación en caso de modificar endpoints, modelos de datos o variables de entorno.

---

## Dudas y Soporte

Si tienes preguntas sobre la arquitectura o necesitas orientación sobre una funcionalidad específica, abre una discusión en el repositorio o contacta al equipo mantenedor. ¡Toda contribución es bienvenida!
