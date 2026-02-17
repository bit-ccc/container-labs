# Container Basics

This chapter provides a high-level overview of containers and the container ecosystem.

## What are Containers?

Containers are lightweight, isolated environments that package an application together with its dependencies. Unlike virtual machines, containers share the host operating system's kernel, making them faster to start and more resource-efficient.

Key benefits:

- **Consistency** - Same environment from development to production
- **Isolation** - Applications run independently without conflicts
- **Portability** - Run anywhere containers are supported
- **Efficiency** - Lower overhead than traditional virtual machines

## What is Docker?

Docker is the most popular platform for building, running, and managing containers. It provides tools to create container images, run containers, and manage container lifecycles.

For a comprehensive introduction, see Docker's official resources:

- [What is a Container?](https://www.docker.com/resources/what-container/) - Docker's explanation of container technology
- [Get Started with Docker](https://docs.docker.com/get-started/) - Official getting started guide
- [Docker Documentation](https://docs.docker.com/) - Complete reference documentation

## Docker Hub

[Docker Hub](https://hub.docker.com/) is Docker's official public registry for container images. It hosts millions of pre-built images that you can use as base images or run directly.

Popular official images include:

- [nginx](https://hub.docker.com/_/nginx) - Web server
- [postgres](https://hub.docker.com/_/postgres) - PostgreSQL database
- [node](https://hub.docker.com/_/node) - Node.js runtime
- [python](https://hub.docker.com/_/python) - Python runtime
- [ubuntu](https://hub.docker.com/_/ubuntu) - A plain Ubuntu image

You can also create a free account to host your own public images. There are also multiple popular alternatives like [quay.io](https://quay.io) (RedHat), [ghcr.io](https://docs.github.com/en/packages/working-with-a-github-packages-registry/working-with-the-container-registry) (GitHub) or selfhosted Image-registries like [Harbor](https://goharbor.io), [GitLab Registry](https://docs.gitlab.com/user/packages/container_registry/) or [Sonatype Nexus](https://www.sonatype.com/products/sonatype-nexus-repository)

## The Open Container Initiative (OCI)

The [Open Container Initiative](https://opencontainers.org/) is an open governance structure that maintains industry standards for container formats and runtimes. This ensures that containers built with one tool can run on any OCI-compliant runtime.

Key OCI specifications:

- **Image Spec** - Defines how container images are structured
- **Runtime Spec** - Defines how containers are executed
- **Distribution Spec** - Defines how images are distributed via registries

Because of OCI standards, you're not locked into Docker - images you build are portable across different container tools.

## Alternative Container Tools

While Docker is the most well-known, several alternative tools are fully compatible with OCI container images:

### Podman

[Podman](https://podman.io/) is a daemonless container engine developed by Red Hat. It's designed as a drop-in replacement for Docker with enhanced security features.

- Runs containers without a daemon (rootless by default)
- Docker-compatible CLI (`alias docker=podman`)
- Supports pods (groups of containers) natively
- [Getting Started with Podman](https://podman.io/get-started)

### nerdctl

[nerdctl](https://github.com/containerd/nerdctl) is a Docker-compatible CLI for containerd. It provides a familiar Docker experience while using containerd directly.

- Docker-compatible commands
- Supports advanced containerd features
- Used in Kubernetes environments
- [nerdctl Documentation](https://github.com/containerd/nerdctl/blob/main/docs/command-reference.md)

### Container Runtimes

Under the hood, container tools use lower-level runtimes:

- [containerd](https://containerd.io/) - Industry-standard runtime used by Docker and Kubernetes
- [CRI-O](https://cri-o.io/) - Lightweight runtime designed specifically for Kubernetes

## Next Steps

Now that you understand the basics, proceed to [02_Docker_CLI](../02_Docker_CLI/README.md) to learn hands-on Docker commands.
