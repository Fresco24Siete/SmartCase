# ============================================================
# SmartCase Frontend (Metro GPS) - Multi-stage Dockerfile
# ============================================================

# Stage 1: Build Flutter Web
FROM debian:bookworm-slim AS builder

WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git unzip xz-utils ca-certificates python3 \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/flutter/flutter.git -b stable /sdks/flutter
ENV PATH="/sdks/flutter/bin:${PATH}"

RUN flutter config --enable-web

COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get

COPY . .
RUN flutter build web --release --pwa-strategy=none --dart-define=API_BASE_URL=http://localhost:8080

# Stage 2: Serve static files with Nginx
FROM nginx:alpine

COPY --from=builder /app/build/web /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
