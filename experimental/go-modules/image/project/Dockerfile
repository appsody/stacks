# Install the app dependencies in a full Node docker image
FROM golang:alpine


# Install user-app dependencies
WORKDIR "/project/user-app"
RUN apk add --update git bash
RUN go get -u github.com/golang/dep/cmd/dep
COPY ./user-app/* ./
RUN ls -ltra /project/user-app
RUN ls -ltra /go
RUN if [ -e /project/user-app/.vendor-me.sh ]; then bash /project/user-app/.vendor-me.sh; fi
RUN go build -o /app ./... 
RUN chmod +x /app
CMD ["/app"]