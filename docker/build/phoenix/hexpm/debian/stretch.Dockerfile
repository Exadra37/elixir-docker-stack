ARG ELIXIR_TAG=latest

FROM exadra37/elixir-dev:${ELIXIR_TAG}

ARG DOCKER_PHOENIX_VERSION=1.6.0

ARG NODE_VERSION=10

USER root

RUN apt update && \
  apt -y upgrade && \
  apt -y install ssh && \

  "${DOCKER_BUILD}"/scripts/nodejs/install.sh "${NODE_VERSION}" && \

  find /usr -type d -name doc | xargs rm -rf && \

  apt -y auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

RUN \
  mkdir /home/developer/.ssh/ && \
  ssh-keyscan -t rsa github.com >>  /home/"${CONTAINER_USER_NAME}"/.ssh/known_hosts && \
  ssh-keyscan -t rsa gitlab.com >> /home/"${CONTAINER_USER_NAME}"/.ssh/known_hosts && \
  "${DOCKER_BUILD}"/scripts/elixir/phoenix/install-from-git-branch.bash \
  "${DOCKER_PHOENIX_VERSION}"

USER root

RUN apt update && apt -y auto-remove

USER "${CONTAINER_USER_NAME}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
