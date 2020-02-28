# Install the app dependencies in a full Node docker image
FROM node:12

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copying individual files/folders as buildah 1.9.0 does not honour .dockerignore
COPY package*.json /project/
COPY *.js /project/
COPY user-app /project/user-app
# Removing node_modules as we can not make assumptions about file structure of user-app
RUN rm -rf /project/user-app/node_modules && mkdir -p /project/user-app/node_modules

# Install stack dependencies
WORKDIR /project
RUN npm install --production

# Install user-app dependencies
WORKDIR /project/user-app
RUN npm install --production

# Creating a tar to work around poor copy performance when using buildah 1.9.0
RUN cd / && tar czf project.tgz project

# Copy the dependencies into a slim Node docker image
FROM node:12-slim

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy project with dependencies
COPY --chown=node:node --from=0 /project.tgz /
RUN tar xf project.tgz && chown -R node:node /project && rm project.tgz

ENV NODE_PATH=/project/user-app/node_modules

ENV NODE_ENV production
ENV PORT 3000

USER node

EXPOSE 3000
CMD ["npm", "start"]
