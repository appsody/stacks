# Dockerfile for building your application.
# Defines the final image that contains content from both the image and template.

FROM registry.access.redhat.com/ubi7/ubi

WORKDIR /project

COPY . ./

EXPOSE 8080

# Pass control your application
CMD ["/bin/bash",  "/project/userapp/hello.sh"]

# Run as a non-root user in group 0.
RUN useradd -u 1001 -r -g 0 -s /usr/sbin/nologin -m default \
  && chown -R 1001:0 /project
USER default

# Install deps (deployable equivalent of APPSODY_PREP).
RUN mkdir -p /project/userapp/deps/installed-during-appsody-build ~/.dep-cache/installed-during-appsody-build
