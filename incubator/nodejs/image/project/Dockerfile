FROM registry.access.redhat.com/ubi8/nodejs-12:1-36

USER root

# Install OS updates
RUN yum install --disableplugin=subscription-manager python2 openssl-devel -y \
 && yum clean --disableplugin=subscription-manager packages \
 && ln -s /usr/bin/python2 /usr/bin/python \
 && useradd --uid 1000 --gid 0 --shell /bin/bash --create-home node

COPY .* /project/
COPY *.* /project/
COPY Dockerfile /project/
COPY user-app /project/user-app/

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app/package*.json ./

# This stack includes two customization points that user projects can utilize if needed.

# npm run build: Run a build phase. Projects that need to execute build commands can 
# customize the 'build' script in their package.json. The build script should call
# 'npm install' if any devDependencies are required at this stage.

# npm run prune: Uninstall dev dependencies, leaving only production dependencies.
# Projects can customize the 'prune' script in their package.json.
# Ideally this would just be 'npm prune', but this command does not have pre/post
# hooks. Instead, the user's 'prune' script can itself call 'npm prune' in addition
# to any additional actions required.

RUN npm install --production \
 && npm run build --if-present \
 && npm run prune --production --if-present \
 && chown -hR node:0 /project \
 && chmod -R g=u /project

WORKDIR "/project/user-app"

ENV NODE_ENV production

USER node

CMD ["npm", "start"]
