FROM ubuntu:24.04

# Copy file inside container
COPY ./hello-world.sh entrypoint.sh
# Run chmod +x to make file executable
RUN chmod +x ./entrypoint.sh

ENTRYPOINT ["./entrypoint.sh"]