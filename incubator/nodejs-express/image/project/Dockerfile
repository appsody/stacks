# Install the app dependencies in a full Node docker image
FROM node:12

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

RUN useradd --gid 0 --shell /bin/bash --create-home node_user

# Copying individual files/folders as buildah 1.9.0 does not honour .dockerignore
COPY package*.json /project/
COPY *.js /project/
COPY user-app /project/user-app
# Removing node_modules as we can not make assumptions about file structure of user-app
RUN rm -rf /project/user-app/node_modules && mkdir -p /project/user-app/node_modules

RUN chown -hR node_user:0 /project \
 && chmod -R g=u /project

USER node_user

# Install stack dependencies
WORKDIR /project
RUN npm install --production

# Install user-app dependencies
WORKDIR /project/user-app
RUN npm install --production

USER root

# Creating a tar to work around poor copy performance when using buildah 1.9.0
RUN cd / && tar czf project.tgz project

# Copy the dependencies into a slim Node docker image
FROM node:12-slim

RUN useradd --gid 0 --shell /bin/bash --create-home node_user

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy project with dependencies
COPY --from=0 /project.tgz /

RUN tar xf project.tgz  \
 && chown -R node_user:0 /project \
 && chmod -R g=u /project \
 && rm project.tgz
 
WORKDIR /project

ENV NODE_PATH=/project/user-app/node_modules

ENV NODE_ENV production
ENV PORT 3000

USER node_user

EXPOSE 3000
CMD ["npm", "start"]
