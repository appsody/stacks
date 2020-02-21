FROM registry.access.redhat.com/ubi8/nodejs-12:1-27

USER root

# Install OS updates
RUN yum upgrade --disableplugin=subscription-manager -y \
 && yum clean --disableplugin=subscription-manager packages \
 && useradd --uid 1000 --gid 0 --shell /bin/bash --create-home node

COPY .* /project/
COPY *.* /project/
COPY Dockerfile /project/
COPY user-app /project/user-app/

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app/package*.json ./

RUN npm install --production \
 && chown -hR node:0 /project \
 && chmod -R g=u /project

WORKDIR "/project/user-app"

ENV NODE_ENV production

USER node

CMD ["npm", "start"]