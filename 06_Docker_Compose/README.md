# Docker Compose

Docker Compose is a tool for defining and running multi-container applications. Instead of running multiple `docker run` commands with various flags, you describe your entire application stack in a single YAML file.

For the complete reference, see the official documentation:
- [Docker Compose Overview](https://docs.docker.com/compose/)
- [Compose File Reference](https://docs.docker.com/compose/compose-file/)

## Compose vs. Docker Run

Everything Docker Compose does can be achieved with regular `docker` commands. Compose simply provides a more convenient, declarative way to manage complex setups.

Consider this compose file:

```yaml
services:
  nginx:
    image: nginx:latest
    restart: unless-stopped
    ports:
      - 80:80
    volumes:
      - nginx-data:/usr/share/nginx/html

volumes:
  nginx-data:
```

The equivalent using Docker CLI commands would be:

```sh
# Create the volume
docker volume create nginx-data

# Run the container
docker run -d \
  --name nginx \
  --restart unless-stopped \
  --publish 80:80 \
  --volume nginx-data:/usr/share/nginx/html \
  nginx:latest
```

For a single container, the difference is minimal. But as your application grows to include databases, caches, and multiple services, managing everything with individual commands becomes error-prone. Compose keeps all configuration in one place and handles the orchestration for you.

## Docker Compose CLI Commands

Here are the most important commands for working with Docker Compose.

### Starting and Stopping

```sh
# Start all services defined in docker-compose.yaml
docker compose up

# Start in detached mode (background)
docker compose up -d

# Stop all services
docker compose down

# Stop and remove volumes (deletes data!)
docker compose down -v
```

### Viewing Status and Logs

```sh
# List running services
docker compose ps

# View logs from all services
docker compose logs

# Follow logs in real-time
docker compose logs -f

# View logs for a specific service
docker compose logs grafana
```

### Managing Individual Services

```sh
# Start a specific service
docker compose up -d grafana

# Stop a specific service
docker compose stop grafana

# Restart a service
docker compose restart grafana

# Execute a command in a running service
docker compose exec grafana /bin/bash
```

### Building and Pulling Images

```sh
# Pull the latest images for all services
docker compose pull

# Build images defined with 'build:' in the compose file
docker compose build

# Build and start
docker compose up --build
```

### Useful Flags

```sh
# Use a specific compose file
docker compose -f production.yaml up -d

# Run in a specific project name (affects container names)
docker compose -p myproject up -d

# Recreate containers even if configuration hasn't changed
docker compose up -d --force-recreate

# Remove orphan containers (services removed from compose file)
docker compose up -d --remove-orphans
```

## Examples

This directory contains two examples demonstrating different aspects of Docker Compose.

### Basic Compose (`basic-compose`)

A minimal example running a single nginx web server with a named volume.

**docker-compose.yaml:**
```yaml
services:
  nginx:
    image: nginx:latest
    restart: unless-stopped
    ports:
      - 80:80
    volumes:
      - nginx-data:/usr/share/nginx/html

volumes:
  nginx-data:
```

Key concepts demonstrated:
- **services** - Defines the containers to run
- **image** - Specifies which image to use
- **restart** - Container restart policy (`unless-stopped` survives host reboots)
- **ports** - Port mapping (host:container)
- **volumes** - Named volume for persistent data

This directory also includes `docker-run.sh`, showing the equivalent Docker CLI command for comparison.

**To run:**
```sh
# From the 06_Docker_Compose/basic-compose directory
docker compose up -d

# Test it
curl http://localhost

# Clean up
docker compose down
```

### Grafana Compose (`grafana-compose`)

A more realistic example running Grafana with a PostgreSQL database backend. This demonstrates how Compose shines for multi-container applications.

**docker-compose.yaml:**
```yaml
services:
  grafana:
    image: grafana/grafana:11.0.0
    restart: unless-stopped
    depends_on:
      - grafana-db
    volumes:
      - grafana-data:/var/lib/grafana
    ports:
      - 127.0.0.1:8070:3000
    networks:
      - grafana-nw
    environment:
      GF_SERVER_DOMAIN: localhost
      GF_DATABASE_TYPE: postgres
      GF_DATABASE_HOST: grafana-db:5432
      GF_DATABASE_USER: grafana
      GF_DATABASE_PASSWORD: CHANGE-ME

  grafana-db:
    image: postgres:15.4
    restart: unless-stopped
    volumes:
      - grafana-db-data:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: grafana
      POSTGRES_USER: grafana
      POSTGRES_PASSWORD: CHANGE-ME
    networks:
      - grafana-nw
    healthcheck:
      test: pg_isready -U grafana -d grafana
      interval: 10s
      timeout: 3s
      start_period: 60s

volumes:
  grafana-data:
  grafana-db-data:

networks:
  grafana-nw:
```

Key concepts demonstrated:
- **depends_on** - Ensures grafana-db starts before grafana
- **networks** - Custom network for container-to-container communication
- **environment** - Environment variables for configuration
- **healthcheck** - Defines how Docker checks if the service is healthy
- **Multiple services** - Both services managed as a single application

Notice how services on the same network can reach each other by service name (`grafana-db:5432`). Docker's internal DNS resolves service names automatically.

**To run:**
```sh
# From the 06_Docker_Compose/grafana-compose directory
docker compose up -d

# Check status
docker compose ps

# View logs
docker compose logs -f

# Access Grafana at http://localhost:8070

# Clean up
docker compose down -v
```

### Env File Compose (`env-file-compose`)

Hard-coding values like ports or image tags directly in `docker-compose.yaml` makes the file harder to reuse across environments. Compose automatically loads a `.env` file from the same directory and substitutes any `${VARIABLE}` references in the compose file.

**.env:**
```sh
NGINX_PORT=8080
NGINX_TAG=1.27
```

**docker-compose.yaml:**
```yaml
services:
  nginx:
    image: nginx:${NGINX_TAG}
    ports:
      - ${NGINX_PORT}:80
```

The `.env` file acts as a set of defaults. You can override individual values at runtime without touching either file:

```sh
# From the 06_Docker_Compose/env-file-compose directory

# Start using values from .env
docker compose up -d

# Override a single variable inline
NGINX_PORT=9090 docker compose up -d

# Inspect which values Compose has resolved
docker compose config
```

**Best practice:** Add `.env` to your `.gitignore` and commit a `.env.example` file with placeholder values instead. This keeps secrets out of version control while documenting which variables are required.

## General Compose File Structure

A typical compose file has three main sections:

```yaml
# Optional: Set a project name
name: my-application

# Required: Define your containers
services:
  service-name:
    image: ...
    # ... service configuration

# Optional: Define named volumes
volumes:
  volume-name:

# Optional: Define custom networks
networks:
  network-name:
```

**Best Practices:**
- Use specific image tags (e.g., `postgres:15.4`) instead of `latest` for reproducibility
- Define healthchecks for services that other services depend on
- Use custom networks to isolate communication between service groups
- Store sensitive values in environment variables or Docker secrets, not in the compose file
