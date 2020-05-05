# Install the app dependencies
FROM swift:5.2 as builder

# Install OS updates
RUN apt-get update \
 && apt-get install -y libcurl4-openssl-dev libssl-dev \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Install user-app dependencies
WORKDIR "/project"
COPY ./user-app ./

# Build project, and discover executable name
RUN echo '#!/bin/bash' > run.sh \
 && swift build -c release | tee output.txt \
 && cat output.txt | awk 'END {print "./.build/x86_64-unknown-linux/release/" $NF}' >> run.sh \
 && chmod 755 run.sh

FROM swift:5.2-slim

# Install OS updates
RUN apt-get update \
 && apt-get clean \
 && echo 'Finished installing dependencies'

WORKDIR "/project"
COPY --from=builder /project/.build /project/.build
COPY --from=builder /project/run.sh /project

ENV PORT 8080
EXPOSE 8080

CMD ["./run.sh"]
