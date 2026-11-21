FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV GODOT_VERSION=4.7.2

RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    wget \
    unzip \
    libfontconfig1 \
    libxcursor1 \
    libxinerama1 \
    libxrandr2 \
    libxi6 \
    libasound2 \
    libpulse0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /server

# Download Godot Linux x86_64 server/editor binary
RUN wget -q https://github.com/godotengine/godot/releases/download/4.7.2-stable/Godot_v4.7.2-stable_linux.x86_64.zip \
    && unzip Godot_v4.7.2-stable_linux.x86_64.zip \
    && mv Godot_v4.7.2-stable_linux.x86_64 /usr/local/bin/godot \
    && chmod +x /usr/local/bin/godot \
    && rm Godot_v4.7.2-stable_linux.x86_64.zip

# Copy project files for dedicated headless simulation
COPY . /server/project

WORKDIR /server/project

COPY deploy/server/entrypoint.sh /server/entrypoint.sh
RUN chmod +x /server/entrypoint.sh

EXPOSE 7777/tcp
EXPOSE 7777/udp

HEALTHCHECK --interval=15s --timeout=5s --start-period=10s --retries=3 \
  CMD pgrep -f godot > /dev/null || exit 1

ENTRYPOINT ["/server/entrypoint.sh"]
