FROM rust:1.37 as builder

WORKDIR "/project/user-app"

# copy dependency files 
COPY /user-app/Cargo.toml Cargo.toml

#ENV PROJECT_NAME="sh -c ./filename.sh"

# get user application dependencies
RUN cargo fetch 

#copy user code
COPY ./user-app/src ./src

# build for release
RUN cargo build --release

FROM rust:1.37-slim-stretch

WORKDIR "/project/user-app"

# reuse build from previous image

COPY --from=builder /project/user-app/target/release/rust-simple .

CMD ["./rust-simple"]