FROM registry.access.redhat.com/ubi8/nodejs-10

USER root

# Install OS updates
RUN yum upgrade -y \
 && yum clean packages \
 && echo 'Finished installing dependencies'

 RUN groupadd --gid 1000 node \
  && useradd --uid 1000 --gid node --shell /bin/bash --create-home node

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app/package*.json ./
RUN npm install --production

RUN chown -R node:node /project

WORKDIR "/project/user-app"

ENV NODE_ENV production

USER node

CMD ["npm", "start"]
