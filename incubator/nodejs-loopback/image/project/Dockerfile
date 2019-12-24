FROM registry.access.redhat.com/ubi8/nodejs-10:1-54

USER root

# Install OS updates
RUN yum upgrade --disableplugin=subscription-manager -y \
 && yum clean --disableplugin=subscription-manager packages \
 && echo 'Finished installing dependencies'

# Install stack dependencies
WORKDIR /project
COPY ./package*.json ./
RUN npm install

# Install user-app dependencies
WORKDIR /project/user-app
COPY ./user-app/package*.json ./

# RUN `npm install` instead of `npm install --production` as we need to transpile TS code
RUN npm install
WORKDIR /project/user-app/node_modules

FROM registry.access.redhat.com/ubi8/nodejs-10:1-54

USER root

# Install OS updates
RUN yum upgrade --disableplugin=subscription-manager -y \
 && yum clean --disableplugin=subscription-manager packages \
 && useradd --uid 1000 --gid 0 --shell /bin/bash --create-home node

RUN mkdir ~/.npm-global

ENV NPM_CONFIG_PREFIX=~/.npm-global

# Copy the project
COPY . /project

# Copy all dependencies
COPY --from=0 /project/node_modules /project/node_modules
COPY --from=0 /project/user-app/node_modules /project/user-app/node_modules

WORKDIR /project

# Make sure TypeScript source code is transpiled
RUN npm run build \
 && npm run build --prefix user-app \
 && chown -hR node:0 /project \
 && chmod -R g=u /project 

ENV NODE_ENV production
ENV PORT 3000

USER node

CMD ["npm", "start"]
