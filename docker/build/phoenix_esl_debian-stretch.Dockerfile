ARG ELIXIR_TAG=latest

FROM exadra37/elixir-dev:${ELIXIR_TAG}

ARG PHOENIX_VERSION=1.4.3
ARG PHOENIX_INSTALL_FROM="hex phx_new ${PHOENIX_VERSION}"
ARG NODE_VERSION=10

USER root

RUN apt update && \
  apt -y upgrade && \

  "${DOCKER_BUILD}"/scripts/nodejs/install.sh "${NODE_VERSION}" && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${CONTAINER_HOME}"

RUN "${DOCKER_BUILD}"/scripts/elixir/phoenix/install.sh "${PHOENIX_VERSION}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
