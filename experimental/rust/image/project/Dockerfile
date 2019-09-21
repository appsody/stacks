FROM rust:1.37 as builder

WORKDIR "/project/user-app"

# copy file and build dependencies without sources
COPY ./user-app/Cargo.toml Cargo.toml

RUN mkdir src/ \
 && echo "fn main() {println!(\"Dummy file to build dependencies.\")}" > src/main.rs \
 && cargo build --release \
 && echo 'Finished installing dependencies'

COPY ./user-app/src ./src/

FROM rust:1.37-slim-stretch

# reuse dependency files from previous image
WORKDIR "/project/user-app"

COPY --from=builder ./project/user-app/Cargo.toml .

COPY --from=builder ./project/user-app/src ./src/

CMD ["cargo", "run", "--release"]