# Install the app dependencies
FROM swift:5.0 as builder

# Install OS updates
RUN apt-get update \
 && apt-get install -y libcurl4-openssl-dev libssl-dev \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app ./
RUN echo "#!/bin/bash" > run.sh \
 && swift build -c release > output.txt \
 && cat output.txt | awk 'END {print $NF}' >> run.sh \
 && chmod 755 run.sh

FROM swift:5.0-slim

# Install OS updates
RUN apt-get update \
 && apt-get install -y libcurl4-openssl-dev libssl-dev \
 && apt-get clean \
 && echo 'Finished installing dependencies'

WORKDIR "/project"
COPY --from=builder /project/user-app/.build /project/.build
COPY --from=builder /project/user-app/run.sh /project

ENV PORT 8080
EXPOSE 8080

CMD ["./run.sh"]
