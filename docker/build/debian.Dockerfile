ARG ELIXIR_VERSION=1.8-slim

FROM elixir:${ELIXIR_VERSION}

ARG CONTAINER_USER_NAME="elixir"
ARG CONTAINER_UID="1000"
ARG CONTAINER_GID="1000"
ARG DISPLAY=":0"
ARG OH_MY_ZSH_THEME="bira"

ARG LANGUAGE_CODE="en"
ARG COUNTRY_CODE="GB"
ARG ENCODING="UTF-8"
ARG LOCALE_STRING="${LANGUAGE_CODE}_${COUNTRY_CODE}"
ARG LOCALIZATION="${LOCALE_STRING}.${ENCODING}"

ARG POSTGRES_VERSION=11

ARG SUBLIME_BUILD=latest
ARG RESOURCES_DIR="/docker-build-resources"

ARG PHOENIX_VERSION=1.4.3
ARG PHOENIX_INSTALL_FROM="hex phx_new ${PHOENIX_VERSION}"
ARG NODE_VERSION=10

ENV DEBIAN_FRONTEND="noninteractive" \
  NO_AT_BRIDGE=1 \
  LANG="${LOCALIZATION}" \
  LC_ALL="${LOCALIZATION}" \
  LANGUAGE="${LOCALE_STRING}:${LANGUAGE_CODE}" \
  WORKSPACE_PATH="/home/${CONTAINER_USER_NAME}/workspace" \
  CONTAINER_HOME="/home/${CONTAINER_USER_NAME}" \
  CONTAINER_BIN_PATH="/home/${CONTAINER_USER_NAME}/bin" \
  CONTAINER_UID=${CONTAINER_UID} \
  CONTAINER_GID=${CONTAINER_GID} \
  DISPLAY=${DISPLAY} \
  PGDATA=/var/lib/postgresql/"${POSTGRES_VERSION}"/main \
  POSTGRES_BIN_PATH=/usr/lib/postgresql/"${POSTGRES_VERSION}"/bin \
  PGUSER=elixir

ENV PATH="${CONTAINER_BIN_PATH}":"${POSTGRES_BIN_PATH}":${PATH}

COPY ./resources /docker-build-resources

RUN \
  apt update && \
  apt -y upgrade && \
  apt -y -q install --no-install-recommends \
    ca-certificates \
    zsh \
    curl \
    less \
    build-essential \
    erlang-dev \
    git && \
  apt -y -q -f install && \

  useradd -m -u "${CONTAINER_UID}" -s /usr/bin/zsh "${CONTAINER_USER_NAME}" && \

  chown --recursive "${CONTAINER_USER_NAME}":"${CONTAINER_USER_NAME}" "${RESOURCES_DIR}" && \

  su "${CONTAINER_USER_NAME}" -c "sh -c 'mkdir -p ${CONTAINER_BIN_PATH}'" && \
  su "${CONTAINER_USER_NAME}" -c "sh -c 'cp -r ${RESOURCES_DIR}/scripts/elixir/bin/* ${CONTAINER_BIN_PATH}'" && \

  "${RESOURCES_DIR}"/scripts/debian/install-locales.sh \
    "${LOCALIZATION}" \
    "${ENCODING}" && \

  "${RESOURCES_DIR}"/scripts/elixir/observer/fix-dependencies.sh && \

  "${RESOURCES_DIR}"/scripts/debian/install-nodejs.sh "${NODE_VERSION}" && \

  "${RESOURCES_DIR}"/scripts/debian/install-pgcli.sh && \

  "${RESOURCES_DIR}"/scripts/debian/install-inotify-tools.sh && \

  "${RESOURCES_DIR}"/scripts/install-oh-my-zsh.sh \
    "${CONTAINER_HOME}" \
    "${OH_MY_ZSH_THEME}" && \

  "${RESOURCES_DIR}"/scripts/create-workspace-dir.sh \
    "${WORKSPACE_PATH}" \
    "${CONTAINER_USER_NAME}" && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${CONTAINER_HOME}"

RUN "${RESOURCES_DIR}"/scripts/elixir/phoenix/install.sh "${PHOENIX_INSTALL_FROM}"

VOLUME ["/var/log/postgresql", "/var/lib/postgresql", "/home/elixir/.config/sublime-text-3"]

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
