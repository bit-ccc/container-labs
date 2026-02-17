This tutorial teaches you the basics of Docker and the Docker CLI through hands-on examples. Whenever you need help, use `docker --help` to see all available commands, or `docker <command> --help` for details about a specific command. For comprehensive documentation, visit the official CLI docs at https://docs.docker.com/reference/cli/docker/.

```sh
docker --help

### OUTPUT ####

# incomplete output of the most important commands
Usage:  docker [OPTIONS] COMMAND

Commands:
  attach      Attach local standard input, output, and error streams to a running container
  create      Create a new container
  logs        Fetch the logs of a container
  pause       Pause all processes within one or more containers
  restart     Restart one or more containers
  rm          Remove one or more containers
  start       Start one or more stopped containers
  stats       Display a live stream of container(s) resource usage statistics
  stop        Stop one or more running containers
  top         Display the running processes of a container
  unpause     Unpause all processes within one or more containers
  update      Update configuration of one or more containers
```

# Docker Hello World

Let's start with the simplest Docker command. The `hello-world` image is a minimal container that prints a message and exits. This is perfect for verifying that Docker is installed correctly and understanding the basic container lifecycle.

```sh
# the most basic docker command
docker run hello-world

### OUTPUT ####

# docker searches for the image locally and pulls it from dockerhub if necessary
# ':latest' is the image tag and is set automatically
Unable to find image 'hello-world:latest' locally

# docker pulls the image from dockerhub
latest: Pulling from library/hello-world
198f93fd5094: Pull complete
Digest: sha256:d4aaab6242e0cace87e2ec17a2ed3d779d18fbfd03042ea58f2995626396a274
Status: Downloaded newer image for hello-world:latest

# the following output comes from within the container
Hello from Docker!
This message shows that your installation appears to be working correctly.

To generate this message, Docker took the following steps:
 1. The Docker client contacted the Docker daemon.
 2. The Docker daemon pulled the "hello-world" image from the Docker Hub.
    (arm64v8)
 3. The Docker daemon created a new container from that image which runs the
    executable that produces the output you are currently reading.
 4. The Docker daemon streamed that output to the Docker client, which sent it
    to your terminal.

To try something more ambitious, you can run an Ubuntu container with:
 $ docker run -it ubuntu bash

Share images, automate workflows, and more with a free Docker ID:
 https://hub.docker.com/

For more examples and ideas, visit:
 https://docs.docker.com/get-started/
```

# Show running containers

The `docker ps` command lists all currently running containers. It shows important information like container ID, image name, status, and exposed ports. This is your first tool for checking what containers are active on your system.

```sh
# show which containers are running right now
docker ps

### OUTPUT ####

# table of running containers - example from a server running a grafana monitoring stack
CONTAINER ID   IMAGE                                        COMMAND                  CREATED        STATUS                    PORTS                                        NAMES
4a9d82fb5eab   grafana/grafana:12.3.1                       "/run.sh"                2 days ago     Up 30 hours               3000/tcp                                     grafana_grafana
9d8342724b39   postgres:18.1                                "docker-entrypoint.s…"   2 days ago     Up 30 hours (healthy)     5432/tcp                                     grafana_grafana-db
d7ec7945ffc9   grafana/loki:3.6.3                           "/usr/bin/loki -conf…"   2 days ago     Up 30 hours               3100/tcp                                     loki_loki
cd66dfe1a73d   gcr.io/cadvisor/cadvisor:v0.55.1             "/usr/bin/cadvisor -…"   2 days ago     Up 30 hours (healthy)     127.0.0.1:8080->8080/tcp                     cadvisor
db16eee82b55   prom/alertmanager:v0.30.0                    "/bin/alertmanager -…"   2 days ago     Up 30 hours (healthy)     9093/tcp                                     alertmanager_alertmanager
91a532a674b8   prom/prometheus:v3.9.1                       "/bin/prometheus --c…"   2 days ago     Up 22 hours (healthy)     9090/tcp                                     prometheus_prometheus
8eeb05d7f4a5   traefik:v3.6.6                               "/entrypoint.sh --lo…"   9 days ago     Up 30 hours (healthy)     0.0.0.0:80->80/tcp, 0.0.0.0:443->443/tcp     traefik_traefik
```

# Docker run & exec

Now that we've seen the basics, let's explore how to run commands inside containers. You can either run a single command that executes and exits, or start an interactive shell session to work inside the container.

## Running containers

### Running a Command in a Container

When you run a command with `docker run`, the container starts, executes the command, and then exits immediately. This is useful for one-off tasks or testing commands in isolated environments.

```sh
# run the whoami command inside the an ubuntu container and exits
# feel free to try other commands
docker run ubuntu whoami

### OUTPUT ####

# most containers use the root user by default
root
```

### Running an interactive Shell

To interact with a container like a regular terminal, use the `-it` flags together. This gives you a shell where you can run multiple commands.

Flags explained:

- `-i` (interactive) - keeps STDIN open so you can type commands
- `-t` (tty) - allocates a pseudo-terminal for a proper shell experience

```sh
# run an interactive shell in an ubuntu container
# feel free to try some shell commands like whoami, ls, cd, ...
docker run -it ubuntu

### OUTPUT ####

root@60966cae4041:/# <yor commands go here - exit with 'exit'>
```

## Working with running Containers

The `docker run` command creates and starts a new container from an image. By default, containers stop when their main process exits. To keep a container running in the background, we use the `-i` (interactive) and `-d` (detached) flags together.

### Setup

First we create an ubuntu container that i named `my-ubuntu` and keeps running

Flags explained:

- `-i` (interactive) - keeps container running (waiting for input)
- `-d` (detached) - runs container in background
- `--name` - assigns a custom name instead of random name

**Note:** If you don't specify a name with `--name`, Docker automatically generates a random name combining an adjective and a famous scientist/developer/... (e.g., `silly_einstein`, `clever_torvalds`, `quirky_curie`). While these names are fun, using custom names makes it easier to identify and manage your containers.

```sh
# create an ubuntu container named my-ubuntu that keeps running
docker run -i -d --name my-ubuntu ubuntu

### OUTPUT ####

# id of the newly created container (you will get a different one)
ff80085d8161935f034b01dd5297d4215061816b19d6ea05fbd8f007d9a75db9
```

### Commands

The `docker exec` command lets you run commands inside an already running container. This is useful for debugging, inspecting the container's state, or performing maintenance tasks without stopping the container.

```sh
# execute whoami in the existing container my-ubuntu
docker exec my-ubuntu whoami

### OUTPUT ####

root
```

Let's open an interactive shell and inspect the running processes. The `ps aux` command shows all processes running inside the container. This helps you understand what's actually happening inside your container.

```sh
# execute a new shell inside the running ubuntu container
docker exec -it my-ubuntu /bin/bash

# run ps aux inside the container to show running processes
ps aux

### OUTPUT ####

USER       PID %CPU %MEM    VSZ   RSS TTY      STAT START   TIME COMMAND
root         1  0.0  0.0   4032  2816 ?        Ss   11:00   0:00 /bin/bash # this is what you started in the setup - keeps the container running
root         7  0.0  0.0   4296  3328 pts/0    Ss   11:03   0:00 /bin/bash # this is your current shell
root        21  0.0  0.0   7628  3456 pts/0    R+   11:07   0:00 ps aux    # this is the 'ps aux' command you just executed
```

### Attach to a running container

While `docker exec` creates a new process inside the container, `docker attach` connects you to the container's main process (PID 1). This is useful when you want to interact with the primary process directly.

```sh
# attach to the running container
docker attach my-ubuntu

### OUTPUT ####

# you are now connected to the main process
# the shell prompt appears (this is the /bin/bash process from setup)
root@ff80085d8161:/#
```

**Detaching without stopping the container:**

To exit the attached session without stopping the container, use the key sequence:

- Press `Ctrl + p`, then `Ctrl + q`

This detaches you from the container while keeping it running in the background.

### Cleanup

When you're done with a container, you need to stop and remove it. Stopping a container halts its processes but keeps the container on your system. To fully clean up, you must also remove the stopped container.

```sh
# stop the my-ubuntu container
docker stop my-ubuntu

# remove the stopped my-ubuntu container
docker rm my-ubuntu
```

# Container Lifecycle

Let's explore the complete container lifecycle. Instead of `docker run` which creates and starts a container in one step, we can control each step separately.

## Create without starting

The `sleep 30` command tells the container to wait for 30 seconds before exiting. This gives us time to experiment with different container states.

```sh
# create a container without starting it
# sleep 30 keeps the container running for 30 seconds
docker create --name lifecycle-demo ubuntu sleep 30

```

## Start the container

```sh
# start the created container
docker start lifecycle-demo

# check if it's running
docker ps
```

## Pause and unpause

Temporarily freeze a running container without stopping it:

```sh
# pause the container (freezes all processes)
docker pause lifecycle-demo

# unpause to resume
docker unpause lifecycle-demo
```

## Restart

```sh
# restart the container
docker restart lifecycle-demo
```

## Cleanup

```sh
# stop the container
docker stop lifecycle-demo

# remove the container
docker rm lifecycle-demo
```

**Container States:**

- **Created** - exists but not started
- **Running** - actively running
- **Paused** - processes frozen
- **Stopped** - has stopped but still exists
- **Removed** - deleted from system

# Environment Variables

Environment variables are the standard way to pass configuration to containers. They allow you to customize container behavior without modifying the image, making your containers flexible and reusable across different environments.

## Setting individual variables with --env

The `--env` (or `-e`) flag sets a single environment variable inside the container.

```sh
# run a container with an environment variable
# printenv <var name> outpts the value of an environment variable
docker run --env MY_NAME=Docker ubuntu printenv MY_NAME

### OUTPUT ####

Docker
```

You can pass multiple environment variables by using the flag multiple times:

```sh
# pass multiple environment variables
# note that we are using sh -c '<command>' to make sure the vars are evaluated inside the container
docker run --env GREETING=Hello --env TARGET=World ubuntu sh -c 'echo $GREETING $TARGET'

### OUTPUT ####
Hello World
```

## Loading variables from a file with --env-file

For multiple variables, it's cleaner to use an environment file. Create a file with your variables (one per line):

```sh
# create an environment file
cat > my-env.txt << 'EOF'
DB_HOST=localhost
DB_PORT=5432
EOF
```

Then load all variables at once:

```sh
# run container with environment file
docker run --env-file my-env.txt ubuntu printenv

### OUTPUT ####

# shows all environment variables including yours
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
HOSTNAME=6d1bb57ce728
DB_HOST=localhost
DB_PORT=5432
HOME=/root
```

## Combining --env and --env-file

You can use both flags together. Individual `--env` values override those from the file:

```sh
# override DB_HOST from the file
docker run --env-file my-env.txt --env DB_HOST=production-db ubuntu printenv DB_HOST

### OUTPUT ####
production-db
```

## Cleanup

```sh
# remove the environment file
rm my-env.txt
```

**Best Practices:**

- Use `--env-file` for multiple related variables (database config, app settings)
- Use `--env` for one-off overrides
- Never commit environment files containing secrets to version control
- Use `.env` as a common naming convention for environment files

# Working with Images

Before you can run containers, you need images. Images are the blueprints that containers are created from. Let's explore how to pull and manage images.

## Pulling images

The `docker pull` command downloads an image from a registry (usually Docker Hub by default).

```sh
# pull the nginx image (uses 'latest' tag by default)
docker pull nginx

### OUTPUT ####

Using default tag: latest
latest: Pulling from library/nginx

# each line represents a layer being downloaded - more on image layers in chapter 5
2ae15a201602: Pull complete
b5de92b86456: Pull complete
ca17c40d702a: Pull complete
e01b5e59ab49: Pull complete
8eb534c72887: Pull complete
b6f45d1635ff: Pull complete
06d013df6a0c: Pull complete
Digest: sha256:7272239bd21472f311aa3e86a85fdca0f1ad648995f983ab6e5e7dea665cd233
Status: Downloaded newer image for nginx:latest
docker.io/library/nginx:latest
```

## Pulling specific versions

You can specify a particular version using tags:

```sh
# pull nginx version 1.26
docker pull nginx:1.26

### OUTPUT ####

1.26: Pulling from library/nginx
# layers are downloaded
Status: Downloaded newer image for nginx:1.26
```

## Pulling from different registries

Docker Hub is the default registry, but you can pull from other registries by specifying the full path:

```sh
# pull from GitLab container registry
docker pull gitlab/gitlab-ce

# pull from Quay.io registry
docker pull quay.io/coreos/etcd

# pull from a private GitLab registry
docker pull registry.gitlab.com/gitlab-org/gitlab-toolbox
```

## Listing images

View all images stored on your system:

```sh
# list all local images
docker image ls

### OUTPUT ####

REPOSITORY                    TAG      IMAGE ID       CREATED       SIZE
nginx                         latest   a1b2c3d4e5f6   7 days ago    187MB
nginx                         1.26     b2c3d4e5f6g7   2 weeks ago   187MB
gitlab/gitlab-ce              latest   c3d4e5f6g7h8   3 weeks ago   3.1GB
quay.io/coreos/etcd          latest   d4e5f6g7h8i9   4 months ago  61.9MB
registry.gitlab.com/...       latest   e5f6g7h8i9j0   5 months ago  419MB
```

Columns explained:

- **REPOSITORY** - the image name (may include registry path)
- **TAG** - the version or variant of the image
- **IMAGE ID** - unique identifier for the image
- **CREATED** - when the image was built
- **SIZE** - disk space used by the image

# Basic Networking - Port Forwarding

When you run a service like a web server inside a container, the easiest way to access it from your host machine is through port forwarding. This maps a port on your localhost to a port inside the container.

## Publishing ports to localhost

The `--publish` (or `-p`) flag forwards a port from your host to the container.

```sh
# run nginx-webserver and forward localhost port 8080 to container port 80
docker run --publish 127.0.0.1:8080:80 nginx

### OUTPUT ####

# nginx starts and is now accessible at http://localhost:8080
/docker-entrypoint.sh: Configuration complete; ready for start up
```

Port mapping format explained:

- `127.0.0.1:8080:80` means:
  - `127.0.0.1` - bind to localhost only (not accessible from network)
  - `8080` - port on your host machine
  - `80` - port inside the container (where nginx listens)

## Testing the connection

Open your browser or use curl to verify nginx is accessible:

```sh
# in a new terminal, test the connection
curl http://localhost:8080

### OUTPUT ####

<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
...
</html>
```

## Running in detached mode

Usually you want containers to run in the background:

```sh
# run nginx in background with port forwarding
docker run -d --publish 127.0.0.1:8080:80 --name my-nginx nginx

### OUTPUT ####

# container ID
a1b2c3d4e5f6g7h8i9j0

# nginx is now running in background and accessible at http://localhost:8080
```

Flags explained:

- `-d` (detached) - runs container in background
- `--publish` - forwards ports (host:container)
- `--name` - assigns a custom name to the container

**Note:** More details about Docker networking, bridge networks, and container-to-container communication will be covered in chapter 03.

# Inspecting Containers

`docker inspect` provides detailed, low-level information about Docker objects, including containers, images, and volumes. It returns a JSON array with rich details about the object's configuration and state.

```sh
# inspect the my-nginx container
docker inspect my-nginx
```

Feel free to run a few containers and familiarize yourself with the output of `docker inspect`. We will use this a lot throughout the course to analyze our setups. 

## Container Logs

`docker logs` fetches the logs of a container. This is essential for debugging and monitoring your applications. For instance, you can use this to monitor the logs of the nginx-webserver we crated in the previous example, without needing to directly attach a shell to the running container.

### Basic Log Output

To see all logs from a container from its start to the current time:

```sh
# show all logs for my-nginx
docker logs my-nginx
```

### Following Logs in Real-Time

To stream logs in real-time, use the `--follow` (or `-f`) flag. The `--timestamps` flag adds a timestamp to each log line.

```sh
# follow logs in real-time with timestamps
docker logs --follow --timestamps my-nginx
```

Now, open another terminal and make a few requests to the `my-nginx` container.

```sh
# in a new terminal
curl http://localhost:8080
curl http://localhost:8080/non-existent-path
```

You will see the access logs appearing in real-time in the first terminal where `docker logs` is running.

```
# output from 'docker logs --follow'
2026-01-19T12:00:05.123456789Z 172.17.0.1 - - [19/Jan/2026:12:00:05 +0000] "GET / HTTP/1.1" 200 615 "-" "curl/8.4.0" "-"
2026-01-19T12:00:10.987654321Z 172.17.0.1 - - [19/Jan/2026:12:00:10 +0000] "GET /non-existent-path HTTP/1.1" 404 153 "-" "curl/8.4.0" "-"
```

### Getting Recent Logs

To retrieve only the most recent log entries, use the `--tail` flag.

```sh
# show the last 10 log lines
docker logs --tail 10 my-nginx
```

# Cleaning Up Resources

To keep your Docker environment tidy, it's important to clean up resources you no longer need. This includes stopping and removing containers.

## Manual Cleanup

First, stop and remove any containers you started manually, like our `my-nginx` web server. Remember: you can use `docker ps` to check which containers are currently running.

```sh
# Stop the running container
docker stop my-nginx

# Remove the stopped container
docker rm my-nginx
```

Containers that have already exited, like `hello-world`, are still on your system. You can see them with `docker ps -a`.

## Automatic Pruning

Docker provides a convenient command to clean up multiple resources at once. To remove all stopped containers, you can use `docker container prune`.

```sh
# Remove all stopped containers
docker container prune

### OUTPUT ####
WARNING! This will remove all stopped containers.
Are you sure you want to continue? [y/N] y
...
```

For a more thorough cleanup, including unused images, networks, and build cache, you can use `docker system prune`.

```sh
# WARNING: This is a more aggressive cleanup.
docker system prune
```

Regularly cleaning up unused resources is a good habit to maintain a healthy Docker environment.

## Cleanup Script
As an easy alternative you might use the `purge-docker-resources.sh` script, included in this repository.

**WARNING:** The script purges any docker resources on your host. Only use it, if you are not using docker for anything else besides this workshop or are absolutely sure you want to purge all docker resoruces, no mather if they are currently running or not.
