FROM debian:buster-slim

ARG DEBIAN_FRONTEND=noninteractive
ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG STEAMCMD_PATH=/opt/steamcmd/steamcmd.sh
ARG LANG=C.UTF-8
ARG LC_ALL=C.UTF-8
ARG DST_USER=dst
ARG DST_GROUP=dst
ARG DST_USER_DATA_PATH=/data
# Keep the following value in sync with scripts/install-dst-server
ARG DST_SERVER_INSTALL_PATH=/opt/dst-server

RUN dpkg --add-architecture i386 \
  && apt update \
  && apt upgrade -y \
  && apt install -y --no-install-recommends \
    ca-certificates \
    wget \
    tini \
    lib32gcc1 \
    lib32stdc++6 \
    libcurl4-gnutls-dev:i386 \
    libcurl4-gnutls-dev \
  && apt autoremove -y \
  && apt clean -y \
  && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["/usr/bin/tini", "--"]

# Create dst user
RUN mkdir -p "$DST_USER_DATA_PATH" \
    && ( groupadd "${DST_GROUP}" || true ) \
    && ( useradd -g "${DST_GROUP}" -d "${DST_USER_DATA_PATH}" "${DST_USER}" || true ) \
    && chown -R "${DST_USER}:${DST_GROUP}" "${DST_USER_DATA_PATH}"

# Install steamcmd
RUN mkdir -p /opt/steamcmd \
    && wget "${STEAMCMD_URL}" -O /tmp/steamcmd.tar.gz \
    && tar -xvzf /tmp/steamcmd.tar.gz -C /opt/steamcmd \
    && rm -rf /tmp/*

COPY scripts /usr/local/bin/

# Install Don't Starve Together Server
RUN mkdir -p "${DST_SERVER_INSTALL_PATH}" \
    && chown -R "${DST_USER}:${DST_GROUP}" "${DST_SERVER_INSTALL_PATH}" \
    && /opt/steamcmd/steamcmd.sh +runscript /usr/local/bin/install-dst-server \
    && rm -rf /root/Steam /root/.steam

ENV DST_USER="${DST_USER}"
ENV DST_GROUP="${DST_GROUP}"
ENV DST_USER_DATA_PATH="${DST_USER_DATA_PATH}"
ENV DST_SERVER_INSTALL_PATH="${DST_SERVER_INSTALL_PATH}"

EXPOSE 10999-11000/udp 12346-12347/udp
CMD ["/usr/local/bin/start.sh"]
