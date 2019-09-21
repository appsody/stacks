FROM rust:1.37 as builder

WORKDIR "/project/user-app"

# copy dependency files 
COPY /user-app/Cargo.toml Cargo.toml

#ENV PROJECT_NAME="sh -c ./filename.sh"

# cache user application dependencies
RUN mkdir src/ \
 && echo "fn main() {println!(\"Dummy file to build dependencies.\")}" > src/main.rs \
 && cargo build --release \
 && echo 'Finished installing dependencies'

#copy user code
COPY ./user-app/src ./src

# build for release
RUN rm -rf target/release/deps/
RUN cargo build --release

FROM rust:1.37-slim-stretch

WORKDIR "/project/user-app"

# reuse build from previous image

COPY --from=builder /project/user-app/target/release/rust-simple .

CMD ["./rust-simple"]