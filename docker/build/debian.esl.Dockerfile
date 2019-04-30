ARG OS_TAG=latest

FROM exadra37/debian-dev:${OS_TAG}

ARG DOCKER_ERLANG_VERSION=22.0
ARG DOCKER_ELIXIR_VERSION=1.8.2

ARG DISPLAY=":0"

ARG PHOENIX_VERSION=1.4.3
ARG PHOENIX_INSTALL_FROM="hex phx_new ${PHOENIX_VERSION}"
ARG NODE_VERSION=10

ARG ERLANG_DOWNLOAD_URL=https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_"${DOCKER_ERLANG_VERSION}"-1~debian~stretch_amd64.deb
ARG ELIXIR_DOWNLOAD_URL=https://packages.erlang-solutions.com/erlang/elixir/FLAVOUR_2_download/elixir_"${DOCKER_ELIXIR_VERSION}"~debian~stretch_amd64.deb

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

  DOCKER_BUILD="/docker-build" && \

  su "${CONTAINER_USER_NAME}" -c "sh -c 'cp -r ${DOCKER_BUILD}/scripts/elixir/bin/* ${CONTAINER_BIN_PATH}'" && \

  "${DOCKER_BUILD}"/scripts/nodejs/install.sh "${NODE_VERSION}" && \

  "${DOCKER_BUILD}"/scripts/postgres/debian/install-pgcli.sh && \

  printf "\nERLANG DOWNLOAD URL: ${ERLANG_DOWNLOAD_URL}\n" && \

  curl -fsSL -o esl.deb "${ERLANG_DOWNLOAD_URL}" && \
  dpkg -i esl.deb && \
  rm -f esl.deb && \

  printf "\nELIXIR DOWNLOAD URL: ${ELIXIR_DOWNLOAD_URL}\n" && \

  curl -fsSL -o elixir.deb "${ELIXIR_DOWNLOAD_URL}" && \
  dpkg -i elixir.deb && \
  rm -f elixir.deb && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${CONTAINER_HOME}"

RUN "${DOCKER_BUILD}"/scripts/elixir/phoenix/install.sh "${PHOENIX_VERSION}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
