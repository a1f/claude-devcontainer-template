# Rust toolchain overlay
# Extra firewall domains: crates.io static.crates.io index.crates.io

RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable
ENV PATH="/home/node/.cargo/bin:$PATH"
RUN cargo install cargo-watch
