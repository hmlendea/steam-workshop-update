# Local test image only.
#
# GitHub Actions runs this action as a composite action so that SteamCMD runs
# natively on the runner. See scripts/install-steamcmd.sh for why the client is
# no longer executed through the runner's Docker daemon.
FROM ubuntu:24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates curl tar lib32gcc-s1 && \
    rm -rf /var/lib/apt/lists/*

ENV STEAMCMD_ROOT=/opt/steamcmd
ENV GITHUB_WORKSPACE=/workspace

COPY scripts/install-steamcmd.sh /opt/action/scripts/install-steamcmd.sh
COPY entrypoint.sh /opt/action/entrypoint.sh

RUN chmod +x /opt/action/scripts/install-steamcmd.sh /opt/action/entrypoint.sh && \
    bash /opt/action/scripts/install-steamcmd.sh

WORKDIR /workspace

ENTRYPOINT ["/opt/action/entrypoint.sh"]
