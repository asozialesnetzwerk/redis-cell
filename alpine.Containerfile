################################ BUILDER ######################################
FROM rust:1.89-alpine AS builder

WORKDIR /redis-cell

RUN apk add --no-cache musl-dev

COPY src ./src
COPY include ./include
COPY Cargo* ./
COPY build.rs .

ENV RUSTFLAGS="-C target-feature=-crt-static"
RUN cargo build --release

################################ RUNTIME ######################################
FROM ghcr.io/asozialesnetzwerk/redis:nightly-alpine AS runtime

COPY --from=builder /redis-cell/target/release/libredis_cell.so /usr/local/lib/redis/modules/libredis_cell.so

RUN apk add --no-cache libgcc

USER redis

CMD ["redis-server", "--loadmodule", "/usr/local/lib/redis/modules/libredis_cell.so"]
