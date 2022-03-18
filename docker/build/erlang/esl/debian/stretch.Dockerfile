ARG OS_TAG=latest

FROM exadra37/debian-dev:${OS_TAG}

ARG DOCKER_ERLANG_VERSION=22.0
ARG DISPLAY=":0"
ARG ERLANG_DOWNLOAD_URL=https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_"${DOCKER_ERLANG_VERSION}"-1~debian~stretch_amd64.deb

ENV DISPLAY=${DISPLAY}

USER root

RUN apt update && \
  apt -y upgrade && \
  apt -y -q install --no-install-recommends \
    build-essential \
    less \
    libcanberra-gtk-module \
    procps \
    libncurses5 \
    libwxbase3.0-0v5 \
    libwxgtk3.0-0v5 \
    libsctp1 && \

  apt -y -f install && \

  curl -fsSL -o esl.deb "${ERLANG_DOWNLOAD_URL}" && \

  curl -fsSL -o esl.deb "${ERLANG_DOWNLOAD_URL}" && \
  dpkg -i esl.deb && \
  rm -f esl.deb && \

  "${DOCKER_BUILD}"/scripts/postgres/debian/install-pgcli.sh && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["erl"]
