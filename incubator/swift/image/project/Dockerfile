# Install the app dependencies
FROM swift:5.0

# Install OS updates
RUN apt-get update \
 && apt-get install -y libcurl4-openssl-dev libssl-dev \
 && apt-get clean \
 && echo 'Finished installing dependencies'

# Install user-app dependencies
WORKDIR "/project/user-app"
COPY ./user-app ./
RUN swift build -c release

CMD ["swift", "run"]
