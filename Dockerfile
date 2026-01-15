FROM dxflrs/garage:v2.1.0 AS garage

FROM debian:trixie-slim

ENV RUST_BACKTRACE=1
ENV RUST_LOG="garage=info"

COPY --from=garage /garage /usr/bin/garage
COPY ./garage.toml /etc/garage.toml
COPY ./init.sh /usr/bin/garage-init
COPY ./healthcheck.sh /usr/bin/garage-healthcheck

RUN chmod +x /usr/bin/garage-init /usr/bin/garage-healthcheck

CMD ["garage-init"]
