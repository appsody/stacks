# Install the app dependencies in a full Node docker image
FROM node:12

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Install stack dependencies
WORKDIR /project/node_modules
WORKDIR /project
COPY ./package*.json ./
# Working around poor performance issue with buildah 1.9.0 as it does not honour .dockerignore.
# Once https://github.com/appsody/appsody-buildah/pull/14 is merged, we can remove the additional steps.
RUN npm install --production && tar czf stack_modules.tgz node_modules && rm -rf node_modules

# Install user-app dependencies
RUN mkdir -p /project/user-app/node_modules
WORKDIR /project/user-app
COPY ./user-app/package*.json ./
# Working around poor performance issue with buildah 1.9.0 as it does not honour .dockerignore.
# Once https://github.com/appsody/appsody-buildah/pull/14 is merged, we can remove the additional steps.
RUN npm install --production && tar czf app_modules.tgz node_modules && rm -rf node_modules

# Copy the dependencies into a slim Node docker image
FROM node:12-slim

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy the project
# Working around poor performance issue with buildah 1.9.0 as it does not honour .dockerignore.
# Once https://github.com/appsody/appsody-buildah/pull/14 is merged, we can remove the additional steps.
COPY --chown=node:node package*.json /project/
COPY --chown=node:node *.js /project/
COPY --chown=node:node user-app /project/user-app

# Copy all app dependencies
WORKDIR /project/user-app
COPY --chown=node:node --from=0 /project/user-app/app_modules.tgz .
RUN tar xf app_modules.tgz && chown -R node:node node_modules && rm app_modules.tgz

# Copy all stack dependencies
WORKDIR /project
COPY --chown=node:node --from=0 /project/stack_modules.tgz .
RUN tar xf stack_modules.tgz && chown -R node:node node_modules && rm stack_modules.tgz

ENV NODE_PATH=/project/user-app/node_modules

ENV NODE_ENV production
ENV PORT 3000

USER node

EXPOSE 3000
CMD ["npm", "start"]
