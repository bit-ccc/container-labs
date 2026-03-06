FROM ubuntu:24.04

# Set build arguent to default value `root`
ARG IMAGE_USER=peter

# Create the new image user if it does not exists
# ||true is a workaround to ignore failure if the user already exists
RUN useradd ${IMAGE_USER} || true

# Set image user
USER ${IMAGE_USER}

CMD ["/bin/whoami"]
