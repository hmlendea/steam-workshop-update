FROM cm2network/steamcmd:latest as steam-workshop-update
RUN apt-get -y update && apt-get install -y wget --no-install-recommends && apt-get clean && rm -rf /var/lib/apt/lists/*

ENV STEAM_USERNAME=
ENV STEAM_PASSWORD=
ENV STEAM_2FASEED=

COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh && \
wget https://github.com/hmlendea/steam-totp/releases/download/v1.0.0/steam-totp_1.0.0_linux-x64 -O /home/steam/steam-totp && \
chmod +x /home/steam/steam-totp

CMD ["."]
ENTRYPOINT ["/entrypoint.sh"]
