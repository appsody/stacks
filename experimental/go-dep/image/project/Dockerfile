# Install the app dependencies in a full Node docker image
FROM golang:alpine


# Install user-app dependencies
WORKDIR "/project/user-app/"
RUN apk add --update git bash
RUN go get -u github.com/golang/dep/cmd/dep
COPY ./user-app /go/src/project/user-app
RUN ls -ltra /go/src/project/user-app
WORKDIR /go/src/project/user-app
RUN dep ensure
RUN go build -o /app ./... 
RUN chmod +x /app
CMD ["/app"]