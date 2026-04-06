# Swift toolchain overlay (Linux server-side / CLI Swift on Debian Bookworm)
# Extra firewall domains: download.swift.org swiftpackageindex.com

ARG SWIFT_VERSION=6.0.3
USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  binutils \
  libc6-dev \
  libcurl4-openssl-dev \
  libedit2 \
  libgcc-12-dev \
  libncurses-dev \
  libpython3-dev \
  libsqlite3-0 \
  libstdc++-12-dev \
  libxml2-dev \
  libz3-dev \
  pkg-config \
  zlib1g-dev \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN ARCH="$(dpkg --print-architecture)" && \
  if [ "$ARCH" = "arm64" ]; then ARCH="aarch64"; else ARCH="x86_64"; fi && \
  curl -fsSL "https://download.swift.org/swift-${SWIFT_VERSION}-release/debian12/${ARCH}/swift-${SWIFT_VERSION}-RELEASE-debian12-${ARCH}.tar.gz" \
  | tar -xz --strip-components=2 -C /usr/local
USER node
