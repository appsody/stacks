# Install the app dependencies in a full Node docker image
FROM node:12

# Copying individual files/folders as buildah 1.9.0 does not honour .dockerignore
COPY user-app /project/user-app
# Removing node_modules as we can not make assumptions about file structure of user-app
RUN rm -rf /project/user-app/node_modules && mkdir -p /project/user-app/node_modules

# Install user-app dependencies
WORKDIR /project/user-app
RUN npm install --production

# Run a build phase. Projects that need to execute build commands can customize the
# 'build' script in their package.json. The build script should call 'npm install'.
# If no build is required, just install production dependencies.
RUN npm run build --if-present

# Uninstall dev dependencies, leaving only production dependencies. Projects can
# customize the 'prune' script in their package.json.
# Ideally this would just be 'npm prune', but this command does not have pre/post
# hooks. Instead, the user's 'prune' script can itself call 'npm prune' in addition
# to any additional actions required.
RUN npm run prune --production --if-present

# Creating a tar to work around poor copy performance when using buildah 1.9.0
RUN cd / && tar czf project.tgz project

# Copy the dependencies into a slim Node docker image
FROM node:12-slim

# Install common dependencies (TLS and CA support)
RUN apt-get update && apt-get install -y libssl1.1 ca-certificates && apt-get clean

# Copy project with dependencies
COPY --chown=node:node --from=0 /project.tgz .
RUN tar xf project.tgz && chown -R node:node project && rm project.tgz

WORKDIR /project/user-app

ENV NODE_ENV production

USER node

CMD ["npm", "start"]
