# Install the app dependencies in a full Node docker image
FROM golang:1.12-alpine3.10


# Install user-app dependencies
WORKDIR "/project/user-app"
RUN apk add --update git bash
COPY ./user-app/* ./
RUN if [ -e /project/user-app/.vendor-me.sh ]; then bash /project/user-app/.vendor-me.sh; fi
RUN go build -o /app ./... 
RUN chmod +x /app
CMD ["/app"]
