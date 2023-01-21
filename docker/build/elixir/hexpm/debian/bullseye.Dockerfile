ARG OS_TAG=stretch-20210902
ARG DOCKER_ERLANG_VERSION=24.1.2
ARG DOCKER_ELIXIR_VERSION=1.12.1

FROM hexpm/elixir:${DOCKER_ELIXIR_VERSION}-erlang-${DOCKER_ERLANG_VERSION}-debian-${OS_TAG}

ENV DOCKER_OS_TAG=${OS_TAG}

ARG DOCKER_BUILD_SCRIPTS_RELEASE=dev-wip

ARG CONTAINER_USER_NAME="developer"
ARG CONTAINER_UID="1000"
ARG CONTAINER_GID="1000"
ARG OH_MY_ZSH_THEME="amuse"

ARG LANGUAGE=""
ARG LANGUAGE_CODE="C"
ARG LOCALE_SEPARATOR=""
ARG COUNTRY_CODE=""
ARG ENCODING="UTF-8"
ARG LOCALE_STRING="${LANGUAGE_CODE}${LOCALE_SEPARATOR}${COUNTRY_CODE}"
ARG LOCALIZATION="${LOCALE_STRING}.${ENCODING}"
ARG DOCKER_BUILD_SCRIPTS_RELEASE=dev-wip

ENV DEBIAN_FRONTEND="noninteractive" \
  NO_AT_BRIDGE=1 \
  LANG="${LOCALIZATION}" \
  LC_ALL="${LOCALIZATION}" \
  LANGUAGE="${LANGUAGE}" \
  DOCKER_BUILD="/docker-build" \
  WORKSPACE_PATH="/home/${CONTAINER_USER_NAME}/workspace" \
  CONTAINER_USER_NAME="${CONTAINER_USER_NAME}" \
  CONTAINER_HOME="/home/${CONTAINER_USER_NAME}" \
  CONTAINER_BIN_PATH="/home/${CONTAINER_USER_NAME}/bin" \
  CONTAINER_UID=${CONTAINER_UID} \
  CONTAINER_GID=${CONTAINER_GID}

RUN \
  apt update && \
  apt -y upgrade && \
  apt -y -q install --no-install-recommends \
    ca-certificates \
    build-essential \
    less \
    nano \
    zsh \
    unzip \
    curl \
    git && \

  mkdir -p "${DOCKER_BUILD}" && \

  curl \
    -fsSl \
    -o archive.tar.gz \
    https://gitlab.com/exadra37-bash/docker/bash-scripts-for-docker-builds/-/archive/"${DOCKER_BUILD_SCRIPTS_RELEASE}"/bash-scripts-for-docker-builds-dev.tar.gz?path=scripts && \

  tar xf archive.tar.gz -C "${DOCKER_BUILD}" --strip 1 && \
  rm -vf archive.tar.gz && \

  "${DOCKER_BUILD}"/scripts/custom-ssl/operating-system/create-and-add-self-signed-root-certificate.sh && \

  "${DOCKER_BUILD}"/scripts/custom-ssl/operating-system/create-self-signed-domain-certificate.sh && \

  "${DOCKER_BUILD}"/scripts/utils/debian/add-user-with-bin-folder.sh \
    "${CONTAINER_USER_NAME}" \
    "${CONTAINER_UID}" \
    "/usr/bin/zsh" \
    "${CONTAINER_BIN_PATH}" && \

  # "${DOCKER_BUILD}"/scripts/debian/install/locales.sh \
  #   "${LOCALIZATION}" \
  #   "${ENCODING}" && \

  "${DOCKER_BUILD}"/scripts/debian/install/inotify-tools.sh && \

  "${DOCKER_BUILD}"/scripts/debian/install/oh-my-zsh.sh \
    "${CONTAINER_HOME}" \
    "${OH_MY_ZSH_THEME}" && \

  "${DOCKER_BUILD}"/scripts/utils/create-workspace-dir.sh \
    "${WORKSPACE_PATH}" \
    "${CONTAINER_USER_NAME}" && \

  # "${DOCKER_BUILD}"/scripts/postgres/debian/install-pgcli.sh && \

  find /usr -type d -name examples | xargs rm -rf && \

  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

RUN mkdir -p ~/.config ~/.local ~/.cache && ls -al ~

RUN mix local.hex --force

WORKDIR "${WORKSPACE_PATH}"

CMD ["zsh"]
