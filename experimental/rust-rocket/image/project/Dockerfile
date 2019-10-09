FROM rust:1.37 as builder

RUN rustup default nightly \
 && rustup update

WORKDIR "/project"

COPY Cargo.toml Cargo.toml

COPY /src/lib.rs /project/src/lib.rs

RUN ls && cd src && cat lib.rs

WORKDIR "/project/user-app"

# copy dependency files 
COPY /user-app/Cargo.toml Cargo.toml

# get user application dependencies
RUN cargo fetch 

#copy user code
COPY /user-app/src ./src

# build for release
RUN cargo build --release

RUN echo "#!/bin/bash" > run.sh \
 && bin=$(find . -maxdepth 3 -perm -111 -type f | grep release/) \
 && echo ./${bin##*/} >> run.sh \
 && chmod 755 run.sh

FROM rust:1.37-slim-stretch

RUN useradd rust

WORKDIR "/project/user-app"

# get files and built binary from previous image
COPY --from=builder /project/user-app/run.sh /project/user-app/Cargo.toml /project/user-app/target/release/ ./

USER rust

ENV ROCKET_ADDRESS=0.0.0.0 

ENV ROCKET_PORT=8000

EXPOSE 8000

CMD ["./run.sh"]