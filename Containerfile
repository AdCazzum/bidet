FROM  rust:1.88.0-trixie
# RUN cargo install mopro-cli
RUN rustup install stable && rustup default stable
