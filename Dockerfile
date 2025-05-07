# -------- Stage 1: Build Container --------
FROM ubuntu:jammy as builder

ENV DEBIAN_FRONTEND=noninteractive

# Install build dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    git \
    portaudio19-dev \
    python3-pip \
    python3-venv \
    avahi-daemon \
    cmake \
    pipx \
    python3-aubio \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PIPX_DEFAULT_PYTHON=/usr/bin/python3

# Install ledfx
# renovate: datasource=pypi depName=ledfx
RUN pipx install 'ledfx==2.0.108'

# -------- Stage 2: Final Runtime Image --------
FROM ghcr.io/linuxserver/baseimage-ubuntu:jammy-version-fb2ecf57

ENV DEBIAN_FRONTEND=noninteractive

# Install runtime dependencies (includes portaudio runtime library)
RUN apt-get update && apt-get install -y \
    python3 \
    python3-aubio \
    libportaudio2 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy ledfx environment
COPY --from=builder /root/.local /root/.local

# Symlink ledfx binary
RUN ln -s /root/.local/bin/ledfx /usr/bin/ledfx

# Add s6 service
COPY root/ /

# Expose LedFx UI port
EXPOSE 8888
