# Go toolchain overlay
# Extra firewall domains: proxy.golang.org sum.golang.org storage.googleapis.com

ARG GO_VERSION=1.23.0
USER root
RUN curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -C /usr/local -xz
USER node
ENV PATH="/usr/local/go/bin:/home/node/go/bin:$PATH"
