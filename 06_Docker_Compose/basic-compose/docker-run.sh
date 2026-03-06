#! /bin/bash

# Basically the corresponding compose file written out as a single docker run command.
docker run --name my-nginx --restart unless-stopped --publish 80:80 --volumes ./nginx-data:/usr/share/nginx/html nginx