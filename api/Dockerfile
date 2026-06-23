# Build stage
FROM golang:1.22-alpine AS builder

WORKDIR /app

# Install build dependencies
RUN apk add --no-cache git gcc musl-dev
RUN go install github.com/cosmtrek/air@v1.49.0

# Copy go.mod and go.sum files
COPY go.mod go.sum ./
# RUN go mod download

# Copy the rest of the application source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o zekdrive-api ./cmd/server/main.go

# Run stage
FROM alpine:3.19

WORKDIR /app

RUN apk add --no-cache ca-certificates tzdata postgresql-client

# Copy the binary from the builder stage
COPY --from=builder /app/zekdrive-api .
COPY --from=builder /app/migrations ./migrations

# Expose the application port
EXPOSE 8080

# Run the binary
CMD ["./zekdrive-api"]
