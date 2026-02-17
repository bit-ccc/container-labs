# Container Crash Course

This repository is a complementary resource for the Container Crash Course by bridgingIT. It covers general container concepts while using Docker as the reference implementation. Each chapter contains hands-on examples and explanations to help you understand containers from the ground up.

## Requirements

### Recommended: Linux Server

The recommended setup is a Linux server (Ubuntu, Fedora, Debian, etc.) with Docker Engine installed. This provides the most straightforward container experience, as close as possible to real-world production setups. You can use any cloud provider or local virtualization environment.

Ensure you have SSH access and follow the official installation guide for your distribution:

- [Install Docker Engine on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
- [Install Docker Engine on Fedora](https://docs.docker.com/engine/install/fedora/)
- [Install Docker Engine on Debian](https://docs.docker.com/engine/install/debian/)
- [Install Docker Engine (all platforms)](https://docs.docker.com/engine/install/)

For Ubuntu, this repository includes a [cloud-config-ubuntu.yaml](./cloud-config-ubuntu.yaml) file that automates the Docker installation. Paste it into your cloud provider's "user data" field when creating a new VM.

Being able to reach additional ports on the server from your workstation is a plus, especially for the networking chapter, but is not required to follow this guide.

### Alternative: Local Virtual Machine

Run a Linux VM locally using VirtualBox, VMware, or Hyper-V. Install your preferred Linux distribution and set up Docker Engine as described above.

### Alternative: Rancher Desktop

[Rancher Desktop](https://rancherdesktop.io/) is a free and open-source application that provides all the essentials to work with containers and Kubernetes on the desktop. It bundles a UI, containerd and the docker cli together with various other tools for working with containers.

### Alternative: Docker Desktop (Windows/Mac)

[Docker Desktop](https://www.docker.com/products/docker-desktop/) is the official desktop application by docker. It provides the docker engine, cli and a simple UI for working with containers.

**Note:** Docker Desktop requires a paid license for commercial use in larger organizations. Check the [Docker Pricing](https://www.docker.com/pricing/) page for details.

## Chapters

| Chapter                                                              | Description                                                                           |
| -------------------------------------------------------------------- | ------------------------------------------------------------------------------------- |
| [01_Container_Basics](./01_Container_Basics/README.md)               | High-level overview of containers, Docker, the OCI standard, and alternative tools    |
| [02_Docker_CLI](./02_Docker_CLI/README.md)                           | Hands-on introduction to the Docker CLI, running containers, and lifecycle management |
| [03_Container_Networking](./03_Container_Networking/README.md)       | Docker networking, bridge networks, and container-to-container communication          |
| [04_Storage_and_Persistance](./04_Storage_and_Persistance/README.md) | Managing persistent data with volumes and bind mounts                                 |
| [05_Images](./05_Images/README.md)                                   | Building custom images with Dockerfiles and pushing to registries                     |
| [06_Docker_Compose](./06_Docker_Compose/README.md)                   | Defining and running multi-container applications                                     |

## Cleanup Script

This repository includes `purge-docker-resources.sh`, a convenience script to reset your Docker environment to a clean state.

```sh
./purge-docker-resources.sh
```

The script stops all running containers and removes all Docker resources including containers, images, volumes, and networks. The script works with any docker cli compatible setup.

**Use with caution:** This script is destructive and irreversible. It will delete all Docker data on your system, including data from projects unrelated to this course. Only use it if Docker setup is dedicated to this workshop, or if you are absolutely certain you want to remove everything. The script will prompt for confirmation before proceeding.
