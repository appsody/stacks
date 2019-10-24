FROM rustlang/rust:nightly as builder

RUN cargo install cargo-edit

WORKDIR "/project"

COPY /deps /project/deps

# copy dependency files 
COPY /copy/Cargo.toml /project

RUN cargo add -q appsody-rocket --path=../deps \
 && mkdir /project/user-app \
 && mv /project/Cargo.toml /project/user-app/

WORKDIR "/project/user-app"
# get user application dependencies
RUN cargo fetch

#copy user code
COPY /user-app/src /project/user-app/src/

ENV ROCKET_ADDRESS=0.0.0.0 

ENV ROCKET_PORT=8000

# build for release
RUN cargo build --release \
 && echo "#!/bin/bash" > run.sh \
 && bin=$(find ./target/release -maxdepth 1 -perm -111 -type f| head -n 1) \
 && echo ./${bin##*/} >> run.sh \
 && chmod 755 run.sh

FROM rust:1.37-slim

WORKDIR "/project"

# get files and built binary from previous image
COPY --from=builder /project/user-app/run.sh /project/user-app/Cargo.toml /project/user-app/target/release/ ./

RUN rm -rf build deps examples incremental

RUN useradd rust

USER rust

EXPOSE 8000

CMD ["./run.sh"]