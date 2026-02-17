This chapter covers Docker container networking fundamentals. You'll learn how containers communicate with each other, how to expose services, and the different networking modes Docker provides. For detailed reference, visit the official networking docs at https://docs.docker.com/network/.

```sh
docker network --help

### OUTPUT ####

Usage:  docker network COMMAND

Manage networks

Commands:
  connect     Connect a container to a network
  create      Create a network
  disconnect  Disconnect a container from a network
  inspect     Display detailed information on one or more networks
  ls          List networks
  prune       Remove all unused networks
  rm          Remove one or more networks
```

# Container Networking Basics

Docker networking enables communication between containers, the Docker host, and external networks. Each container has its own isolated network stack, meaning it functions like an independent host with its own IP address and network interfaces. This prevents port conflicts between applications running in different containers.

To allow communication, containers are connected to Docker networks. By default, all containers are connected to a shared `bridge` network, allowing them to find each other. Throughout this module we will discover multiple ways of using docker networks to enable communication between different containers and also the outside world.

Docker offers several network drivers, each suited for different use cases. The most common ones are:
- `bridge`: The default driver for standalone containers.
- `host`: Removes network isolation, sharing the host's networking stack.
- `overlay`: For multi-host communication in a swarm. - Out of scope for this guide.
- `none`: Disables all networking for a container.

## Listing networks

First let us take a look at the default networks configured on any docker host:

```sh
# list all networks
docker network ls

### OUTPUT ####

NETWORK ID     NAME      DRIVER    SCOPE
a1b2c3d4e5f6   bridge    bridge    local    # <- default bridge network
b2c3d4e5f6g7   host      host      local    # <- host network
c3d4e5f6g7h8   none      null      local    # <- helper for isolating containers
```
Later in this course we will create additonal custom networks. Use the `docker network ls` command, whenever you need an overview of the currently setup networks.


# Bridge Networks: The Basics

A bridge network in Docker operates like a virtual network switch inside the Docker host. When containers are connected to the same bridge network, they can communicate with each other using their internal IP addresses, just as if they were physical machines connected to the same local network.

## The Default Bridge Network

When you start Docker, it automatically creates a default bridge network named `bridge`. If you run a container without specifying a network, it will automatically connect to this default bridge. While convenient for getting started, the default bridge network has limitations, especially regarding service discovery. It's generally recommended to create your own user-defined bridge networks for better isolation and features.

## Containers on the default network

When you run a container without specifying a network, it connects to the default bridge network:

```sh
# run two containers on the default bridge network
docker run -d --name web1 nginx
docker run -d --name web2 nginx

# inspect the bridge network to see connected containers
docker network inspect bridge

### OUTPUT ####

[
    {
        "Name": "bridge",
        "Driver": "bridge",
        "Containers": {
            "a1b2c3d4...": {
                "Name": "web1",
                "IPv4Address": "172.17.0.2/16"
            },
            "b2c3d4e5...": {
                "Name": "web2",
                "IPv4Address": "172.17.0.3/16"
            }
        }
    }
]
```

### Communicating Between Containers

Containers on the same bridge network can communicate using their internal IP addresses. Let's verify this.

First, find the IP address of `web1` from the `docker network inspect bridge` command above. We'll assume it's `172.17.0.2` for this example.

Next, open a new terminal and monitor the logs of the `web1` container. This will allow you to see the access log when we connect to it.
```sh
# In a new terminal, follow the logs of web1
docker logs -f web1
```

Now, let's run `curl` from another container to `web1`. We'll use the `nicolaka/netshoot` image, which is a popular debugging image that comes with `curl` and other networking tools pre-installed.

We will also use the `--rm` flag, which automatically removes the container after it exits. This is great for keeping your system clean when running temporary tasks.

```sh
# Run a temporary netshoot container to access web1 by its IP
docker run --rm -it nicolaka/netshoot /bin/bash

# Run curl inside netshoot container to access web1
curl http://172.17.0.2

### OUTPUT from curl ###
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

In the terminal where you are monitoring the logs, you will see a new entry appear:

```
# Expected output from 'docker logs -f web1'
172.17.0.4 - - [19/Jan/2026:12:00:00 +0000] "GET / HTTP/1.1" 200 612 "-" "curl/7.88.1" "-"
```

This confirms that `web1` received the request and that containers on the default bridge can reach each other by IP.

### Communicating from the Host

On most Linux systems, the Docker host can communicate directly with containers on the bridge network using their internal IP addresses.

```sh
# From your host machine's terminal (may not work on Docker Desktop for Mac/Windows)
curl http://172.17.0.2

### OUTPUT ###
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

**Note:** This direct access from the host is a feature of how Docker networking is implemented on Linux. On Docker Desktop for Mac and Windows, you typically cannot reach the internal container IP directly from the host and must rely on published ports, which we will cover later.

## User-Defined Networks for a Three-Tier Application

Creating your own custom bridge networks is highly recommended. They provide significant advantages over the default `bridge` network:

*   **Automatic Service Discovery:** Containers can communicate using their names instead of IP addresses.
*   **Improved Isolation:** You can segment your application by connecting containers only to the networks they need.

To demonstrate this, we'll build a classic three-tier application step-by-step. The application consists of:
*   `web`: The user-facing web frontend.
*   `api`: A backend API.
*   `db`: A database.

We will use custom images for each service, available at `ghcr.io/bit-ccc/<image-name>`. These images are based on `netshoot` to include various tools for network debugging and run a small HTTP server.

### Part 1: Setting Up the Backend

First, let's create the backend of our application. The `api` needs to communicate with the `db`, so we'll place them on a dedicated network called `backend-net`.

**Step 1.1: Create the Backend Network**
```sh
# Create a dedicated network for the backend
docker network create backend-net
```

**Step 1.2: Deploy the Backend Containers**
```sh
# Run the database on the backend network
docker run -d --name db --network backend-net ghcr.io/bit-ccc/postgresql-db

# Run the API on the backend network
docker run -d --name api --network backend-net ghcr.io/bit-ccc/api
```

**Step 1.3: Verify Backend Communication**
Now, let's confirm that the `api` can reach the `db` using its container name.

```sh
# From the 'api' container, curl the 'db' by name on its port 5432
docker exec api curl http://db:5432

### OUTPUT ###
This is the postgresql-db.
```
Success! The containers on our custom `backend-net` can resolve each other by name.

### Part 2: Adding the Frontend and a Multi-Homed API

Now, let's add the `web` frontend. The frontend should only talk to the `api`, not the database. We will achieve this by creating a second network, `frontend-net`, and connecting the `api` to it, making it "multi-homed".

**Step 2.1: Create the Frontend Network**
```sh
# Create a network for frontend to api communication
docker network create frontend-net
```

**Step 2.2: Deploy the Frontend Container**
```sh
# Run the frontend container on the new frontend network
docker run -d --name web --network frontend-net ghcr.io/bit-ccc/web-frontend
```

**Step 2.3: Connect the API to the Frontend Network**
This is the key step. We connect the *already running* `api` container to `frontend-net`. It will now be connected to both `backend-net` and `frontend-net`.

```sh
# Connect the 'api' container to the 'frontend-net'
docker network connect frontend-net api
```
You can inspect the `api` container (`docker inspect api`) to see its connections to both networks.

**Step 2.4: Verify the Full Application**

Let's run our tests again to ensure everything is working as designed.

**Test 1: Can the frontend reach the API? (Should work)**
```sh
# From the 'web' container, curl the 'api' by name on its port 8080
docker exec web curl http://api:8080

### OUTPUT ###
This is the API.
```

**Test 2: Can the frontend reach the database? (Should FAIL)**
This confirms our security and isolation. The `web` container has no route to the `db`.
```sh
# From the 'web' container, try to curl the 'db'. This will fail.
docker exec web curl http://db:5432

### OUTPUT ###
curl: (6) Could not resolve host: db
```
The setup is working perfectly. The frontend can reach the API, but it is completely isolated from the database.

### Disconnecting from a Network

You can also dynamically disconnect a container from a network. For example, to remove the `api`'s access to the `frontend-net`:

```sh
# Disconnect the 'api' container from the 'frontend-net'
docker network disconnect frontend-net api
```
After running this, the `web` container would no longer be able to reach the `api`.

# Publishing Ports

Publishing ports makes container services accessible from outside the container network. There are several ways to publish ports, each with different behavior. Run the different opions and try to connect to your container. You might use curl, a webbrowser or even another device for thesting this.

## Publish to random port in all interfaces
**WARNING:** Do not try this step in a public or insecure network environment.

```sh
# publish container port 80 to random host port on ALL network interfaces
docker run -d --publish 80 --name web-random nginx

# list containers to find the randomly selected port
docker ps
```

Port format: `--publish 80` means:

- `80` - port in the container

This makes the service accessible from ANY network interface, including external networks. The container is reachable from:

- `localhost:32768`
- Your machine's local IP (e.g., `192.168.1.100:32768`)
- External networks if your firewall allows it

## Publish to different host port
**WARNING:** Do not try this step in a public or insecure network environment.

```sh
# publish container port 80 to host port 8080 on all interfaces
docker run -d --publish 8080:80 --name web-8080 nginx
```

This format: `--publish 8080:80` means:

- Container's port `80` is accessible on host's port `8080`
- Useful when host port 80 is already in use
- Still accessible from all network interfaces

## Publish to localhost only

```sh
# publish container port 80 to localhost port 8080 only
docker run -d --publish 127.0.0.1:8080:80 --name web-local nginx
```

This format: `--publish 127.0.0.1:8080:80` means:

- `127.0.0.1` - bind to localhost only
- `8080` - port on your host
- `80` - port in the container

**Recommended:** This is the safest option for development. The service is only accessible from:

- `localhost:8080`
- `127.0.0.1:8080`

The service is NOT accessible from external networks or other machines.

## Summary of publish formats

```sh
# Format 1: container-port only (random host port, all interfaces)
--publish 80

# Format 2: host-port:container-port (all interfaces)
--publish 8080:80

# Format 2: ip:host-port:container-port (specific interface)
--publish 127.0.0.1:8080:80
```

# EXPOSE vs PUBLISH

The `EXPOSE` directive in Dockerfiles and `--expose` flag are often confused with `--publish`, but they serve different purposes.

## EXPOSE - Documentation only

`EXPOSE` is metadata that documents which ports the container listens on. It does NOT publish ports or make them accessible from outside:

```sh
# expose documents port 80 but doesn't publish it
docker run -d --expose 80 --name web-expose nginx

# port 80 is NOT accessible from the host
curl http://localhost:80

### OUTPUT ####

curl: (7) Failed to connect to localhost port 80: Connection refused
```

`EXPOSE` is useful for:

- Documentation - telling users which ports the container uses
- Container-to-container communication on the same network
- Works with `-P` flag to publish all exposed ports

## Publish all exposed ports

```sh
# -P publishes all EXPOSE'd ports to random host ports
docker run -d -P --name web-P nginx

# check which random port was assigned
docker port web

### OUTPUT ####

80/tcp -> 0.0.0.0:32768
```

The `-P` flag automatically publishes all `EXPOSE`d ports to random high-numbered ports on all interfaces. Be careful with this there are very few reasons you would want to publish random ports.

## When to use EXPOSE vs PUBLISH

- **EXPOSE** - use in Dockerfiles to document which ports your application uses (more on this in Module 05)
- **--publish** - use when running containers to actually make ports accessible

```dockerfile
# In Dockerfile - document the port
EXPOSE 80

# When running - actually publish it
docker run -d --publish 127.0.0.1:8080:80 myimage
```

# Host Network Mode

Host mode removes network isolation - the container uses the host's network stack directly. This means the container shares the host's IP address and can access all network interfaces.

## Using host network

```sh
# run container with host network mode
docker run -d --network host --name web-host nginx

# nginx binds directly to host's port 80
# no port publishing needed
curl http://localhost:80

### OUTPUT ####

<!DOCTYPE html>
<html>
<title>Welcome to nginx!</title>
...
```

In host mode:

- No network isolation between container and host
- Container uses host's IP address
- No `--publish` needed - services bind directly to host ports
- Container can see all host network interfaces
- Port conflicts happen at the host level

## When to use host mode

Use cases:

- **Performance** - eliminates network translation overhead
- **Network tools** - containers that need direct network access
- **Legacy apps** - applications that need specific network configurations

Drawbacks:

- **Security** - container has full access to host network
- **Port conflicts** - multiple containers can't use the same port
- **Portability** - behavior may differ across operating systems

## Host mode example

```sh
# run a network monitoring tool with host network access
docker run -it --network host --name monitor nicolaka/netshoot

# run ip addr inside monitor container to show all network interfaces
# the container can see all host network interfaces
ip addr

### OUTPUT ####

1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536
    inet 127.0.0.1/8 scope host lo
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 192.168.1.100/24 brd 192.168.1.255 scope global eth0
# ... host's actual network interfaces
```

# Network Commands Reference

Quick reference for common networking commands:

```sh
# List all networks
docker network ls

# Create a network
docker network create my-network

# Inspect a network
docker network inspect my-network

# Connect a running container to a network
docker network connect my-network container-name

# Disconnect a container from a network
docker network disconnect my-network container-name

# Remove a network
docker network rm my-network

# Remove all unused networks
docker network prune
```

# Best Practices

1. **Use custom networks** - Always create custom networks for your applications instead of using the default bridge network
2. **Localhost binding** - Use `127.0.0.1:port:port` for local development to prevent external access
3. **Name-based communication** - Use container names instead of IP addresses on custom networks
4. **Network segmentation** - Use separate networks for containers that do not need to communicate with eachother
5. **Avoid host mode** - Only use host networking when absolutely necessary
6. **Document with EXPOSE** - Always add EXPOSE to Dockerfiles to document ports
7. **Explicit publishing** - Use `--publish` explicitly rather than relying on `-P`
