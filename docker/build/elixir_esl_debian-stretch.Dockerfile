ARG ERLANG_TAG=latest

FROM exadra37/erlang-dev:${ERLANG_TAG}

ARG DOCKER_ELIXIR_VERSION=1.8.2

ARG ELIXIR_DOWNLOAD_URL=https://packages.erlang-solutions.com/erlang/elixir/FLAVOUR_2_download/elixir_"${DOCKER_ELIXIR_VERSION}"~debian~stretch_amd64.deb

USER root

RUN apt update && \
  apt -y upgrade && \

  su "${CONTAINER_USER_NAME}" -c "sh -c 'cp -r ${DOCKER_BUILD}/scripts/elixir/bin/* ${CONTAINER_BIN_PATH}'" && \

  printf "\nELIXIR DOWNLOAD URL: ${ELIXIR_DOWNLOAD_URL}\n" && \

  curl -fsSL -o elixir.deb "${ELIXIR_DOWNLOAD_URL}" && \
  dpkg -i elixir.deb && \
  rm -f elixir.deb && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
