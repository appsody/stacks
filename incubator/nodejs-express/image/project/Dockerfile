# Install the app dependencies in a full Node docker image
FROM node:12

RUN useradd -m node_user && groupadd node_group

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
FROM node:12-slim

RUN useradd -m node_user && groupadd node_group

# Install OS updates
RUN apt-get update \
 && apt-get dist-upgrade -y \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy the project
COPY --chown=node_user:node_group . /project

# Copy all dependencies
COPY --chown=node_user:node_group --from=0 /project/node_modules /project/node_modules
COPY --chown=node_user:node_group --from=0 /project/user-app/node_modules /project/user-app/node_modules

RUN chown -hR node:0 /project \
 && chmod -R g=u /project

WORKDIR /project

ENV NODE_PATH=/project/user-app/node_modules

ENV NODE_ENV production
ENV PORT 3000

USER node_user

EXPOSE 3000
CMD ["npm", "start"]
