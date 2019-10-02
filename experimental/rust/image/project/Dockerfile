FROM rust:1.37 as builder

WORKDIR "/project/user-app"

COPY filename.sh .

# copy dependency files 
COPY /user-app/Cargo.toml Cargo.toml

# get user application dependencies
RUN cargo fetch 

#copy user code
COPY /user-app/src ./src

# build for release
RUN cargo build --release

FROM rust:1.37-slim-stretch

RUN useradd rust

WORKDIR "/project/user-app"

# get files and built binary from previous image
COPY --from=builder /project/user-app/filename.sh /project/user-app/Cargo.toml /project/user-app/target/release/ ./

RUN chmod +x filename.sh \
 && chown rust:rust $(./filename.sh)

USER rust

ENV PORT 8000

EXPOSE 8000

CMD ["bash", "-c", "./$(./filename.sh)"]