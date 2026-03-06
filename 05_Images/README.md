# Docker Images and Building

This chapter covers Docker Images, the blueprints of containers. You will learn how to manage images, how to write your own `Dockerfile` to create custom images, and the best practices for building efficient and secure images.

For a deep dive into build CLI commands use the following page: https://docs.docker.com/engine/reference/commandline/image

For details on available instructions in Dockerfiles use the official reference: https://docs.docker.com/reference/dockerfile

## What is a Docker Image?

A Docker image is a read-only template that contains a set of instructions for creating a container. An image includes an application's code, a runtime, libraries, environment variables, and configuration files. Containers are runnable instances of an image.

## Basic Image Management

Here are the most common commands for managing images on your local system.

```sh
# List all images on your system
docker image ls

# Download an image from a registry (like Docker Hub)
docker pull ubuntu:24.04

# Remove an image from your system
docker image rm ubuntu:24.04

# Inspect an image to see its layers and metadata
docker image inspect ubuntu:24.04
```

## Building Images with a Dockerfile

A `Dockerfile` is a text document that contains all the commands a user could call on the command line to assemble an image. `docker build` is the command that builds an image from a `Dockerfile`.

Let's explore the key `Dockerfile` instructions by examining the examples in this directory.

### 01: Basic Example (`01_basic_example`)

This example builds a simple image that runs a "Hello World" shell script. Feel free to first take a quick look at the `hello-world.sh` script, available in the directory.

**Dockerfile:**
```dockerfile
FROM ubuntu:24.04

# Copy file inside container
COPY ./hello-world.sh entrypoint.sh
# Run chmod +x to make file executable
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
```

*   `FROM`: Specifies the base image to start from (`ubuntu:24.04`).
*   `COPY`: Copies the local `hello-world.sh` file into the image as `entrypoint.sh`.
*   `RUN`: Executes a command in a new layer. Here, we make our script executable.
*   `ENTRYPOINT`: Defines which command should be executed, when the container is started.

**To build and run:**
```sh
# From the 05_Images/01_basic_example directory
docker build -t basic-example .
docker run --rm basic-example
```

**Understanding the build command:**

The `docker build` command has two important parts that beginners often find confusing:

- **`-t basic-example`** - The `-t` (or `--tag`) flag assigns a name (and optionally a tag) to your image. Without this flag, Docker would only assign a random ID to your image, making it hard to reference later. The format is `-t name:tag` (e.g., `-t basic-example:1.0`). If you omit the tag, Docker uses `latest` by default.

- **`.` (the dot)** - This is the *build context*. It tells Docker which directory contains the files needed for the build. The dot (`.`) means "the current directory". Docker sends all files from this directory to the Docker daemon, where they can be used by `COPY` and `ADD` instructions. This is why you run the build command from inside the example directory.

```sh
# These are equivalent when run from the example directory:
docker build -t basic-example .
docker build -t basic-example ./

# You can also specify a different context path:
docker build -t basic-example /path/to/build/context

# Or build from a parent directory by specifying the Dockerfile location:
docker build -t basic-example -f 01_basic_example/Dockerfile 01_basic_example/
```

### 02: Environment Variables (`02_advanced_example`)

This example introduces environment variables and a more advanced `COPY` command.

**Dockerfile:**
```dockerfile
FROM ubuntu:24.04

# Set env var
ENV MY_NAME=Peter

# Copy file and set chmod on the fly
# This is essentailly a combination of the COPY and RUN command from the previous example
COPY --chmod=770 hello-world.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
```

*   `ENV`: Sets a persistent environment variable `MY_NAME` to `Peter`. This variable is available at build time and when containers are run from the image.
*   `COPY --chmod`: A convenient way to copy a file and set its permissions in one step. `--chown` is also available to change ownership of a copied file or directory.

**To build and run:**
```sh
# From the 05_Images/02_advanced_example directory
docker build -t advanced-example .
docker run --rm advanced-example

### OUTPUT ####
Hello Peter!

# You can also override the environment variable at runtime
docker run --rm -e MY_NAME=World advanced-example

### OUTPUT ####
Hello World!
```

### 03: Users and Build Arguments (`03_user_example`)

This example demonstrates how to change the user, when building an image. Running containers as a non-root user is a critical security best practice. In addition we can use the `ARG` directive to provide build time arguments.

**Dockerfile:**
```dockerfile
FROM ubuntu:24.04

# Set build arguent to default value `peter`
ARG IMAGE_USER=peter

# Create the new image user if it does not exists
# ||true is a workaround to ignore failure if the user already exists
RUN useradd ${IMAGE_USER} || true

# Set image user
USER ${IMAGE_USER}

CMD ["/bin/whoami"]
```

*   `ARG`: Defines a build-time variable. Unlike `ENV`, `ARG` variables are not available in the running container unless they are also used to set an `ENV` variable.
*   `USER`: Sets the user name (or UID) to use when running the image.
*   `CMD`: Sets the default command to execute when the container starts. It can be easily overridden from the command line.

**To build and run:**
```sh
# From the 05_Images/03_user_example directory
# Build with the default root user
docker build -t user-example .
docker run --rm user-example

### OUTPUT ####
peter

# Build with a custom non-root user
docker build --build-arg IMAGE_USER=max -t user-example-max .
docker run --rm user-example-max

### OUTPUT ####
max
```

## CMD vs ENTRYPOINT

Both `CMD` and `ENTRYPOINT` define what command runs when a container starts, but they behave differently. Understanding the difference is essential for building flexible images.

### CMD - Default Command (easily overridden)

`CMD` sets the default command and/or arguments for your container. Users can easily override it by appending a command to `docker run`.

```dockerfile
FROM ubuntu:24.04
CMD ["echo", "Hello from CMD"]
```

```sh
# Run with default CMD
docker run --rm cmd-example

### OUTPUT ####
Hello from CMD

# Override CMD completely by adding a command
docker run --rm cmd-example echo "I replaced CMD"

### OUTPUT ####
I replaced CMD

# Run a different command entirely
docker run --rm cmd-example whoami

### OUTPUT ####
root
```

**Key point:** When you provide a command to `docker run`, it *replaces* the entire `CMD`.

### ENTRYPOINT - Fixed Executable (harder to override)

`ENTRYPOINT` configures the container to run as an executable. Arguments passed to `docker run` are *appended* to the entrypoint, not replacing it.

```dockerfile
FROM ubuntu:24.04
ENTRYPOINT ["echo", "Hello"]
```

```sh
# Run with no arguments
docker run --rm entrypoint-example

### OUTPUT ####
Hello

# Arguments are APPENDED to ENTRYPOINT
docker run --rm entrypoint-example World

### OUTPUT ####
Hello World

# Multiple arguments work too
docker run --rm entrypoint-example from Docker

### OUTPUT ####
Hello from Docker
```

**Key point:** `ENTRYPOINT` makes your container behave like a command-line tool. Users provide arguments, not replacement commands.

### Combining CMD and ENTRYPOINT (Best Practice)

The most powerful pattern combines both: `ENTRYPOINT` defines the executable, and `CMD` provides default arguments that users can override.

**Example (`04_cmd_entrypoint_example`):**

```dockerfile
FROM ubuntu:24.04

# ENTRYPOINT defines the executable
ENTRYPOINT ["echo"]

# CMD provides default arguments to ENTRYPOINT
CMD ["Hello from Docker!"]
```

```sh
# From the 05_Images/04_cmd_entrypoint_example directory
docker build -t greeting .

# Run with default message (uses CMD)
docker run --rm greeting

### OUTPUT ####
Hello from Docker!

# Override just the arguments (CMD is replaced, ENTRYPOINT stays)
docker run --rm greeting "Custom message here"

### OUTPUT ####
Custom message here

# Pass multiple arguments
docker run --rm greeting Hello World from the CLI

### OUTPUT ####
Hello World from the CLI
```

### Quick Reference Table

| Dockerfile | `docker run image` | `docker run image arg1` |
|------------|-------------------|------------------------|
| `CMD ["a", "b"]` | runs `a b` | runs `arg1` |
| `ENTRYPOINT ["a", "b"]` | runs `a b` | runs `a b arg1` |
| `ENTRYPOINT ["a"]` + `CMD ["b"]` | runs `a b` | runs `a arg1` |

### When to Use Which

- **Use `CMD` alone** when you want users to easily run different commands in your container (like a base OS image).
- **Use `ENTRYPOINT` alone** when your container should always run a specific program (like a compiled binary).
- **Use both together** when you have a fixed program that accepts configurable arguments (like a CLI tool with default options).

## More Dockerfile Instructions

### 05: `ADD` vs. `COPY` (`05_add_example`)

The `ADD` instruction has more features than `COPY`. It can fetch remote URLs and auto-extract tar files.

**Dockerfile:**
```dockerfile
FROM ubuntu:24.04

# Add README.md from external  URL
ADD https://raw.githubusercontent.com/docker/compose/refs/heads/main/README.md compose-readme.md

CMD ["/bin/cat", "compose-readme.md"]
```

```sh
# From the 05_Images/05_add_example directory
docker build -t add-example .

# Run the image --> Outputs the README.md content fetched from GitHub
docker run --rm add-example

### OUTPUT ####
# Table of Contents
- [Docker Compose](#docker-compose)
- [Where to get Docker Compose](#where-to-get-docker-compose)
    + [Windows and macOS](#windows-and-macos)
...
```

**Best Practice:** Prefer `COPY` over `ADD`. `COPY` is more transparent and predictable. Use `ADD` only when you specifically need its features, like adding a file from a URL or auto-extracting an archive.

### 06: Advanced `RUN` (`06_advanced_run_example`)

This example shows a more complex build step, including installing packages and using a bind mount during the build.

**Dockerfile:**
```dockerfile
FROM ubuntu:24.04

# Run apt udate and install jq
RUN apt update && apt install -y jq

# Mount and execute setup.sh
RUN --mount=type=bind,source=./setup.sh,target=/setup.sh ./setup.sh

ENTRYPOINT ["/bin/bash"]
```

This Dockerfile demonstrates two important optimization techniques:

**Chaining commands with `&&` (reducing layers):**

Each `RUN` instruction creates a new layer in the image. Combining related commands with `&&` reduces the number of layers and can significantly reduce image size. For example:

```dockerfile
# Bad: Creates 2 layers, and the apt cache remains in the first layer
RUN apt update
RUN apt install -y jq

# Good: Creates 1 layer
RUN apt update && apt install -y jq

# Even better: Cleans up apt cache in the same layer
RUN apt update && apt install -y jq && rm -rf /var/lib/apt/lists/*
```

**`RUN --mount=type=bind` (files not included in image):**

The `--mount` option allows you to temporarily mount files into the build container. The key benefit is that **mounted files are NOT included in the final image layers**. This is useful for:

*   Build scripts you don't want in the final image
*   Bundling various commands into a single layer
*   Secret files (credentials, keys) needed only during build
*   Large files needed temporarily (like installers)

In this example, `setup.sh` is mounted and executed, but will not be present in the final image. If we had used `COPY` instead, the script would remain in the image, increasing its size and potentially exposing implementation details.

### 07: Multi-Stage Builds (`07_multistage_example`)

Multi-stage builds are a key technique for creating small, secure production images. You use one stage with a full build environment to compile your code, and a second, minimal stage to copy *only* the compiled artifact into.

**Dockerfile:**
```dockerfile
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
```
This process results in a tiny final image containing just the Alpine OS and your single Go binary, instead of the entire Go toolchain.

This directory also contains a `.dockerignore` file. Any files or directories listed in `.dockerignore` are excluded from the files sent to the Docker daemon during the build, which can speed up builds and avoid including sensitive information.

### 08: Health Checks (`08_healthcheck_example`)

A `HEALTHCHECK` instruction tells Docker how to test a container to check that it is still working.

**Dockerfile:**
```dockerfile
FROM nginx:latest

# Add a basic healthcheck on to the default nginx image
HEALTHCHECK CMD curl -sf -o /dev/null http://localhost/ || exit 1
```
When you run `docker ps`, you will see the container's health status (e.g., `(healthy)`, `(unhealthy)`). This is useful for orchestration systems to know if they should restart a container.

### 09: Build Cache (`09_cache_example`)

Docker builds images layer by layer. After a successful build, Docker **caches each layer**. On the next build, Docker reuses a cached layer if neither the instruction nor any files it depends on have changed. As soon as one layer is invalidated, **all subsequent layers are rebuilt** — even if they haven't changed. Understanding this rule is key to writing fast Dockerfiles.

This example uses two Dockerfiles and a `process.sh` script to illustrate the difference.

**Dockerfile.script-first — poor cache usage:**
```dockerfile
FROM ubuntu:24.04

# Step 1: Copy the script first
COPY process.sh /process.sh
RUN chmod +x /process.sh

# Step 2: Install jq
# Changing process.sh will invalidate THIS layer too, forcing a slow re-download
RUN apt update && apt install -y jq && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/process.sh"]
```

**Dockerfile.install-first — good cache usage:**
```dockerfile
FROM ubuntu:24.04

# Step 1: Install jq first (stable, rarely changes)
# Docker caches this layer based on the instruction text, not upstream package
# versions. A new jq release will NOT invalidate the cache automatically.
RUN apt update && apt install -y jq && rm -rf /var/lib/apt/lists/*

# Step 2: Copy the script last (changes frequently)
# Only this layer is invalidated when process.sh is edited
COPY process.sh /process.sh
RUN chmod +x /process.sh

ENTRYPOINT ["/process.sh"]
```

**To build and observe caching:**
```sh
# From the 05_Images/09_cache_example directory

# --- Round 1: build both images from scratch ---
docker build -t cache-bad  -f Dockerfile.script-first  .
docker build -t cache-good -f Dockerfile.install-first .

# --- Simulate a code change ---
echo '# changed' >> process.sh

# --- Round 2: rebuild and watch the output ---
# BAD: "apt install" step runs again because process.sh was copied before it
docker build -t cache-bad  -f Dockerfile.script-first  .

# GOOD: "apt install" step is restored from cache; only the COPY step reruns
docker build -t cache-good -f Dockerfile.install-first .

# Run either image
docker run --rm cache-good
```

**What to look for in the output:**

*   Lines starting with `CACHED` mean Docker reused an existing layer — no work was done.
*   Lines starting with a step number (e.g., `Step 3/5`) without `CACHED` mean Docker rebuilt that layer.

**A note on cache invalidation for packages:**

Docker invalidates a `RUN` layer only when the **instruction text** changes. It does **not** query upstream repositories to check for newer package versions. If you want to force a fresh `apt install` (e.g., to pick up a security update), use the `--no-cache` flag to disable the cache for an entire build:

```sh
# Rebuild every layer from scratch, ignoring all cached layers
docker build --no-cache -t cache-good -f Dockerfile.install-first .
```

**The rule of thumb:**

Order your instructions from **least frequently changed** to **most frequently changed**. Put slow, stable steps (package installation, dependency downloads) near the top, and fast, volatile steps (copying your own source code) near the bottom. This maximises the number of layers that can be served from cache.

## Tagging Images

Tags are labels used to version and identify images. The full format is `registry/repository:tag`.

**Understanding the tag format:**

The registry is always part of the full image name, even when it's not visible:

```
registry.example.com / my-username / my-app : 1.0
|___________________| |___________| |______| |___|
      registry         namespace     image    tag
```

When you omit the registry, Docker assumes `docker.io` (Docker Hub). These are equivalent:

```sh
docker pull nginx:latest
docker pull docker.io/library/nginx:latest
```

For other registries, you must include the full path:

```sh
# GitHub Container Registry
docker pull ghcr.io/owner/image:tag

# Google Container Registry
docker pull gcr.io/project/image:tag

# Self-hosted registry
docker pull registry.mycompany.com/team/image:tag
```

**During Build:**
You can tag an image during the build with the `-t` flag.
```sh
docker build -t my-app:1.0 .
```

**After Build:**
You can add a tag to an existing image using `docker tag`. This is useful for preparing an image to be pushed to a different repository.
```sh
# Tag our local image for Docker Hub
docker tag my-app:1.0 my-dockerhub-username/my-app:1.0

# Tag the same image for a different registry
docker tag my-app:1.0 ghcr.io/my-github-username/my-app:1.0
```

## Pushing Images to Docker Hub
**HINT:** This requires a Docker Hub account or write access to any other container registry. You may create a free Docker Hub account at https://app.docker.com/signup

To share your images, you can push them to a registry. Docker Hub is the default public registry.

**1. Log in to Docker Hub:**
```sh
docker login

### OUTPUT ####
Login with your Docker ID to push and pull images from Docker Hub.
Username: your-username
Password:
Login Succeeded
```

**2. Tag your image with your Docker Hub username:**

Your image name must include your Docker Hub username as the namespace. Without it, Docker won't know where to push the image.

```sh
# Tag with your username
docker tag my-app:1.0 your-username/my-app:1.0
```

**3. Push the image:**
```sh
docker push your-username/my-app:1.0

### OUTPUT ####
The push refers to repository [docker.io/your-username/my-app]
a1b2c3d4e5f6: Pushed
b2c3d4e5f6g7: Pushed
1.0: digest: sha256:abc123... size: 1234
```

Your image is now publicly available and others can pull it with:
```sh
docker pull your-username/my-app:1.0
```

**Note:** For private repositories or other registries, the process is similar - just include the full registry path in your tag and authenticate with `docker login registry.example.com`.
