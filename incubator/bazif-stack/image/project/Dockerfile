# Install the app dependencies in a full Node docker image
FROM node:10

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Install stack dependencies
WORKDIR /project
COPY ./package*.json ./
RUN npm install --production

# Install user-app dependencies
WORKDIR /project/user-app
COPY ./user-app/package*.json ./
RUN npm install --production
WORKDIR /project/user-app/node_modules

# Copy the dependencies into a slim Node docker image
FROM node:10-slim

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy the project
COPY --chown=node:node . /project

# Copy all dependencies
COPY --chown=node:node --from=0 /project/node_modules /project/node_modules
COPY --chown=node:node --from=0 /project/user-app/node_modules /project/user-app/node_modules

WORKDIR /project

ENV NODE_ENV production
ENV PORT 3000

USER node

EXPOSE 3000
CMD ["npm", "start"]