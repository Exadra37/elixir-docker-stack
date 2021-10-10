ARG ERLANG_TAG=latest

FROM exadra37/erlang-dev:${ERLANG_TAG}

ARG DOCKER_ELIXIR_VERSION=1.8.2

USER root

RUN apt update && \
  apt -y upgrade && \

  su "${CONTAINER_USER_NAME}" -c "sh -c 'cp -r ${DOCKER_BUILD}/scripts/elixir/bin/* ${CONTAINER_BIN_PATH}'" && \

  "${DOCKER_BUILD}"/scripts/elixir/install-from-git-branch.bash \
    "${DOCKER_ELIXIR_VERSION}" && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
