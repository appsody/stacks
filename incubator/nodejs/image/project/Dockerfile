# Install the app dependencies in a full Node docker image
FROM node:12

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

WORKDIR "/project/user-app/node_modules"

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app/package*.json ./
RUN npm install --production && ls -al && tar czf app_modules.tgz node_modules

# Copy the dependencies into a slim Node docker image
FROM node:12-slim

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy the project
COPY --chown=node:node package*.json /project
COPY --chown=node:node user-app /project/user-app

# Copy all dependencies
WORKDIR "/project/user-app"
COPY --chown=node:node --from=0 /project/user-app/app_modules.tgz .
RUN tar xf app_modules.tgz && chown -R node:node node_modules && rm app_modules.tgz

ENV NODE_ENV production

USER node

CMD ["npm", "start"]