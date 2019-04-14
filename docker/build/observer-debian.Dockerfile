ARG ELIXIR_VERSION=latest

FROM elixir:${ELIXIR_VERSION}

ARG CONTAINER_USER_NAME="observer"
ARG CONTAINER_UID="1000"
ARG CONTAINER_GID="1000"
ARG DISPLAY=":0"
ARG OH_MY_ZSH_THEME="bira"

ENV DEBIAN_FRONTEND="noninteractive" \
  NO_AT_BRIDGE=1 \
  DISPLAY=${DISPLAY} \
  CONTAINER_USER_NAME="${CONTAINER_USER_NAME}" \
  CONTAINER_HOME="/home/${CONTAINER_USER_NAME}" \
  CONTAINER_UID=${CONTAINER_UID} \
  CONTAINER_GID=${CONTAINER_GID} \
  RESOURCES_DIR=/docker-build-resources \
  WORKSPACE_PATH="/home/${CONTAINER_USER_NAME}/workspace"


COPY ./resources /docker-build-resources

RUN apt update && \
  apt -y upgrade && \
  apt install -y --no-install-recommends \
    zsh \
    libcanberra-gtk-module && \

  useradd -m -u "${CONTAINER_UID}" -s /usr/bin/zsh "${CONTAINER_USER_NAME}" && \

  su "${CONTAINER_USER_NAME}" -c "sh -c 'mkdir -p ${CONTAINER_HOME}/.local/share'" && \

  "${RESOURCES_DIR}"/scripts/install-oh-my-zsh.sh \
    "${CONTAINER_HOME}" \
    "${OH_MY_ZSH_THEME}" && \

  "${RESOURCES_DIR}"/scripts/create-workspace-dir.sh \
    "${WORKSPACE_PATH}" \
    "${CONTAINER_USER_NAME}"

USER "${CONTAINER_USER_NAME}"

WORKDIR "${CONTAINER_HOME}"

ENV PATH="${CONTAINER_HOME}"/observer_cli/_build/default/bin:${PATH}

RUN git clone https://github.com/zhongwencool/observer_cli.git && \
  cd observer_cli && \
  rebar3 escriptize

WORKDIR "${CONTAINER_HOME}/observer_cli"

CMD ["erl", "-hidden", "-run", "observer"]