FROM golang:1

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive
ENV GOPATH /go
RUN go get -u github.com/golang/dep/cmd/dep

COPY . /go/src/app

WORKDIR /go/src/app
RUN dep ensure

ENTRYPOINT ["go"]
CMD ["run", "."]
