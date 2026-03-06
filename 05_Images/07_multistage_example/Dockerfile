### Build Image
# Use golang image for build stage
FROM golang:1.23-alpine AS builder

WORKDIR /go/src/app
COPY main.go .

# Run go build
RUN go build -o /go/bin/app main.go

### Release Image
# Start over with a clean alpine image
FROM alpine:latest

# Copy final go binary from previous stage
COPY --from=builder /go/bin/app /usr/local/bin/app

ENTRYPOINT ["app"]