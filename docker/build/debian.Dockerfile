ARG ELIXIR_VERSION=1.8

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
ARG DOCKER_BUILD_RESOURCES_DIR="/docker-build-resources"

ARG PHOENIX_VERSION=1.4.3
ARG PHOENIX_INSTALL_FROM="hex phx_new ${PHOENIX_VERSION}"

ENV DEBIAN_FRONTEND="noninteractive" \
  LANG="${LOCALIZATION}" \
  LC_ALL="${LOCALIZATION}" \
  LANGUAGE="${LOCALE_STRING}:${LANGUAGE_CODE}" \
  WORKSPACE_PATH="/home/${CONTAINER_USER_NAME}/workspace" \
  CONTAINER_HOME="/home/${CONTAINER_USER_NAME}" \
  CONTAINER_UID=${CONTAINER_UID} \
  CONTAINER_GID=${CONTAINER_GID} \
  DISPLAY=${DISPLAY} \
  PGDATA=/var/lib/postgresql/"${POSTGRES_VERSION}"/main \
  POSTGRES_BIN_PATH=/usr/lib/postgresql/"${POSTGRES_VERSION}"/bin \
  PGUSER=elixir

ENV PATH="${CONTAINER_HOME}/bin":"${POSTGRES_BIN_PATH}":${PATH}

COPY ./resources /docker-build-resources

RUN apt update && \
  apt -y upgrade && \
  apt -y install \
    curl \
    less \
    git \
    nodejs \
    dbus* && \
  apt -y -f install && \

  useradd -m -u "${CONTAINER_UID}" -s /usr/bin/zsh "${CONTAINER_USER_NAME}" && \

  chown -R "${CONTAINER_USER_NAME}":"${CONTAINER_USER_NAME}" "${DOCKER_BUILD_RESOURCES_DIR}" && \

  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/debian/install-locales.sh \
    "${LOCALIZATION}" \
    "${ENCODING}" && \

  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/debian/install-postgres.sh \
    "stretch" \
    "11" \
    "${CONTAINER_USER_NAME}" && \

  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/debian/install-pgcli.sh && \

  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/debian/install-inotify-tools.sh && \

  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/install-oh-my-zsh.sh \
    "${CONTAINER_HOME}" \
    "${OH_MY_ZSH_THEME}" && \

  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/create-workspace-dir.sh \
    "${WORKSPACE_PATH}" \
    "${CONTAINER_USER_NAME}"

USER "${CONTAINER_USER_NAME}"

RUN "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/setup-postgres.sh "11" "postgres" "postgres" && \
  "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/install-phoenix.sh "${PHOENIX_INSTALL_FROM}"


###############
# EDITORS
###############

USER root

RUN "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/debian/install-visual-studio-code.sh

RUN "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/debian/install-sublime-text.sh \
  "${CONTAINER_USER_NAME}" \
  "${SUBLIME_BUILD}"

##### END #####

USER "${CONTAINER_USER_NAME}"

RUN "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/sublime-text-3/setup.sh \
      "${CONTAINER_HOME}" \
      "${DOCKER_BUILD_RESOURCES_DIR}" && \
    "${DOCKER_BUILD_RESOURCES_DIR}"/scripts/sublime-text-3/install-elixir-language-server.sh \
      "${CONTAINER_HOME}"

VOLUME ["/var/log/postgresql", "/var/lib/postgresql"]

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
