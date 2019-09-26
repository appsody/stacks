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

COPY --from=builder /project/user-app/filename.sh .
RUN chmod +x filename.sh

COPY --from=builder /project/user-app/Cargo.toml .

# get built binary from previous image
COPY --from=builder /project/user-app/target/release/ .

RUN chown rust:rust $(./filename.sh)

USER rust

CMD ["bash", "-c", "./$(./filename.sh)"]