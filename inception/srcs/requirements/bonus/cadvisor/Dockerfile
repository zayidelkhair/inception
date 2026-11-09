# ==============================================================================
# 📜 FILE: srcs/requirements/bonus/cadvisor/Dockerfile
# 👤 AUTHOR: zsid-ele <zsid-ele@student.42abudhabi.ae>
# 🏫 SCHOOL: 42 Abu Dhabi
# 🎯 PURPOSE:
#    This Dockerfile builds the container image for cAdvisor (Container Advisor)
#    to monitor resource usage and performance characteristics of running containers.
# ==============================================================================

FROM debian:bookworm

LABEL maintainer="zsid-ele <zsid-ele@student.42abudhabi.ae>"
LABEL project="Inception - 42 Abu Dhabi"

RUN apt-get update && \
    apt-get install -y --no-install-recommends wget ca-certificates && \
    rm -rf /var/lib/apt/lists/*

RUN wget -O /usr/local/bin/cadvisor https://github.com/google/cadvisor/releases/download/v0.49.1/cadvisor-v0.49.1-linux-amd64 && \
    chmod +x /usr/local/bin/cadvisor

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/cadvisor", "-logtostderr"]

