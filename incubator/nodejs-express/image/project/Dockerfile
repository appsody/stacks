FROM registry.access.redhat.com/ubi8/nodejs-10:1-66

USER root

# Install OS updates
RUN yum upgrade --disableplugin=subscription-manager -y \
 && yum install --disableplugin=subscription-manager python2 -y \
 && yum clean --disableplugin=subscription-manager packages \
 && ln -s /usr/bin/python2 /usr/bin/python \
 && useradd --uid 1000 --gid 0 --shell /bin/bash --create-home node

# Install stack dependencies
WORKDIR /project
COPY ./package*.json ./
RUN npm install --production

# Install user-app dependencies
WORKDIR /project/user-app
COPY ./user-app/package*.json ./
RUN npm install --production

COPY .* /project/
COPY *.* /project/
COPY Dockerfile /project/
COPY test /project/test/
COPY user-app /project/user-app/

RUN chown -hR node:0 /project \
 && chmod -R g=u /project

WORKDIR /project

ENV NODE_PATH=/project/user-app/node_modules

ENV NODE_ENV production
ENV PORT 3000

USER node

EXPOSE 3000
CMD ["npm", "start"]
