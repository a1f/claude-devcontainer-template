# Python toolchain overlay
# Extra firewall domains: pypi.org files.pythonhosted.org

USER root
RUN apt-get update && apt-get install -y --no-install-recommends \
  python3 python3-pip python3-venv \
  && apt-get clean && rm -rf /var/lib/apt/lists/*
USER node

RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/home/node/.local/bin:$PATH"
