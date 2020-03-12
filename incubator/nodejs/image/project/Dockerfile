# Install (build) stage: use a full image
FROM node:12

# Copying individual srcs with buildah 1.9.0 does not honour .dockerignore, so
# afterwards remove node_modules as it was installed for host OS architecture.
COPY --chown=node:node user-app /project/user-app
RUN rm -rf /project/user-app/node_modules

# Install the user-app
USER node
WORKDIR /project/user-app
RUN npm install --production

# Creating a tar to work around poor copy performance when using buildah 1.9.0
USER root
RUN cd / && tar czf project.tgz /project


# Run stage: use a slim image
FROM node:12-slim

# Copy installed app from build stage
COPY --from=0 /project.tgz .
RUN tar xf project.tgz && chown -R node:node project && rm project.tgz

# Start the app
WORKDIR /project/user-app
ENV NODE_ENV production
USER node
CMD ["npm", "start"]
