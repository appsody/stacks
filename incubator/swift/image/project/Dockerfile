# Install the app dependencies
FROM swift:5.1 as builder

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app ./

# Build project, and discover executable name
RUN echo "#!/bin/bash" > run.sh \
 && swift build -c release | tee output.txt \
 && cat output.txt | awk 'END {print $NF}' >> run.sh \
 && chmod 755 run.sh

FROM swift:5.1-slim

WORKDIR "/project"
COPY --from=builder /project/user-app/.build /project/.build
COPY --from=builder /project/user-app/run.sh /project

ENV PORT 8080
EXPOSE 8080

CMD ["./run.sh"]
