FROM nginx:latest

# Add a basic healthcheck on to the default nginx image
HEALTHCHECK CMD curl -sf -o /dev/null http://localhost/ || exit 1