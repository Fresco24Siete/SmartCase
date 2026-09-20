# ============================================================
# SmartCase API Backend - Multi-stage Dockerfile
# ============================================================

# Stage 1: Build stage
FROM golang:alpine AS builder

WORKDIR /app

ENV GOTOOLCHAIN=auto

RUN apk add --no-cache ca-certificates git

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-w -s" -o smartcase-backend ./cmd/api

# Stage 2: Lightweight runtime stage
FROM alpine:3.19

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata

COPY --from=builder /app/smartcase-backend /app/smartcase-backend

EXPOSE 8080

CMD ["/app/smartcase-backend"]
