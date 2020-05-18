FROM dev.local/appsody/rust-tide as server

FROM rust:1.43.1-buster as builder

COPY --from=server /project/server /project/server

WORKDIR "/project/user-app"

COPY * /project/user-app/

# get user application dependencies
RUN cargo fetch 

#copy user code
COPY user-app/src /project/user-app/

WORKDIR "/project/server/bin"

# build for release
RUN cargo build --release \
 && echo "#!/bin/bash" > run.sh \
 && bin=$(find ./target/release -maxdepth 1 -perm -111 -type f| head -n 1) \
 && echo ./${bin##*/} >> run.sh \
 && chmod 755 run.sh

FROM debian:buster-slim

RUN useradd rust

WORKDIR "/project/user-app"

# get files and built binary from previous image
COPY --from=builder /project/server/bin/run.sh /project/server/bin/Cargo.toml /project/server/bin/target/release/ ./

USER rust

ENV PORT 8000

EXPOSE 8000

CMD ["./run.sh"]
