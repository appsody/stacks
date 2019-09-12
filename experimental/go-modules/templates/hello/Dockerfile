FROM golang:1

# Avoid warnings by switching to noninteractive
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /app
COPY . /app
RUN go build .

ENTRYPOINT ["go"]
CMD ["run", "."]
