FROM ubuntu:24.04

# Set env var
ENV MY_NAME=Peter

# Copy file and set chmod on the fly
COPY --chmod=770 hello-world.sh entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]
