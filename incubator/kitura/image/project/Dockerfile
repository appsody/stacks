# Install the app dependencies
FROM swift:5.1 as builder

# Install OS updates
RUN apt-get update \
 && apt-get install -y zlib1g-dev libcurl4-openssl-dev libssl-dev \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Copy extracted project
WORKDIR "/project"
COPY . /project

# Replace dependencies with a pristine copy, in case they have been modified
RUN rm -rf /project/user-app/.appsody
COPY ./deps /project/user-app/.appsody

# Build project, and discover executable name
WORKDIR "/project/user-app"
RUN echo '#!/bin/bash' > run.sh \
 && swift build -c release | tee output.txt \
 && cat output.txt | awk 'END {print "./.build/x86_64-unknown-linux/release/" $NF}' >> run.sh \
 && chmod 755 run.sh

FROM swift:5.1-slim

# Define a kitura user
RUN useradd -ms /bin/bash kitura

# Copy built project
COPY --chown=kitura:kitura --from=builder /project /project

# Configure listening port
ENV PORT 8080
EXPOSE 8080

# Run application as kitura user
USER kitura
WORKDIR "/project/user-app"
CMD ["./run.sh"]
