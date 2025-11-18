ARG ELIXIR_TAG=latest

FROM exadra37/elixir-dev:${ELIXIR_TAG}

ARG DOCKER_PHOENIX_VERSION=1.8.1

ARG NODE_VERSION=24

USER root

RUN apt update
RUN apt -y upgrade

RUN apt -y install --no-install-recommends ssh

RUN "${DOCKER_BUILD}"/scripts/nodejs/install.sh "${NODE_VERSION}"

# RUN find /usr -type d -name doc | xargs rm -rf

RUN apt -y install --no-install-recommends tree

RUN apt -y auto-remove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

RUN \
  mkdir /home/"${CONTAINER_USER_NAME}"/.ssh/ && \
  ssh-keyscan -t rsa github.com >>  /home/"${CONTAINER_USER_NAME}"/.ssh/known_hosts && \
  ssh-keyscan -t rsa gitlab.com >> /home/"${CONTAINER_USER_NAME}"/.ssh/known_hosts && \
  "${DOCKER_BUILD}"/scripts/elixir/phoenix/install-from-git-branch.bash \
  "${DOCKER_PHOENIX_VERSION}"

RUN mix archive.install --force hex igniter_new

# ARG RUST_VERSION=1.77.1
# ENV RUST_VERSION=${RUST_VERSION}

# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain=${RUST_VERSION} -y
# RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# ENV PATH="~/.cargo/bin:$PATH"
# RUN bash -c "cargo --version"
# RUN bash -c "cargo install tauri-cli"

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
