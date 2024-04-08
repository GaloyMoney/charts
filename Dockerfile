# Use alpine Linux as the base image
FROM alpine:latest

# Install curl
RUN apk add --no-cache curl

# Define the command to run when the container starts
CMD ["echo", "Hello, Kaniko!"]
