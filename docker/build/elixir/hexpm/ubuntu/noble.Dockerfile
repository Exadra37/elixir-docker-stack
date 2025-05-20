ARG OS_TAG=noble-20250415.1
ARG DOCKER_ERLANG_VERSION=27.3.4
ARG DOCKER_ELIXIR_VERSION=1.18.3

FROM hexpm/elixir:${DOCKER_ELIXIR_VERSION}-erlang-${DOCKER_ERLANG_VERSION}-ubuntu-${OS_TAG}

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
    git

RUN mkdir -p "${DOCKER_BUILD}" && \
   curl \
    -fsSl \
    -o archive.tar.gz \
    https://gitlab.com/exadra37-bash/docker/bash-scripts-for-docker-builds/-/archive/"${DOCKER_BUILD_SCRIPTS_RELEASE}"/bash-scripts-for-docker-builds-dev.tar.gz?path=scripts

RUN tar xf archive.tar.gz -C "${DOCKER_BUILD}" --strip 1 && \
  rm -vf archive.tar.gz

RUN "${DOCKER_BUILD}"/scripts/custom-ssl/operating-system/create-and-add-self-signed-root-certificate.sh

RUN "${DOCKER_BUILD}"/scripts/custom-ssl/operating-system/create-self-signed-domain-certificate.sh

RUN if bash -c "id -u ${CONTAINER_UID} &> /dev/null"; then OLD_USER_NAME=$(bash -c "id -un ${CONTAINER_UID}"); usermod -l "${CONTAINER_USER_NAME}" -m -d /home/${CONTAINER_USER_NAME} -s /bin/bash "${OLD_USER_NAME}"; groupmod -n "${CONTAINER_USER_NAME}" "${OLD_USER_NAME}"; else useradd -m -u ${CONTAINER_UID} -s /bin/bash ${CONTAINER_USER_NAME}; fi

  # "${DOCKER_BUILD}"/scripts/debian/install/locales.sh \
  #   "${LOCALIZATION}" \
  #   "${ENCODING}" && \

RUN "${DOCKER_BUILD}"/scripts/debian/install/inotify-tools.sh

RUN "${DOCKER_BUILD}"/scripts/debian/install/oh-my-zsh.sh \
    "${CONTAINER_HOME}" \
    "${OH_MY_ZSH_THEME}"

RUN "${DOCKER_BUILD}"/scripts/utils/create-workspace-dir.sh \
    "${WORKSPACE_PATH}" \
    "${CONTAINER_USER_NAME}"

  # "${DOCKER_BUILD}"/scripts/postgres/debian/install-pgcli.sh && \

RUN find /usr -type d -name examples | xargs rm -rf

# RUN apt install -y python2

RUN ln -s /usr/bin/python3 /usr/bin/python

RUN apt auto-remove && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

RUN mkdir -p ~/.config ~/.local ~/.cache ~/bin

RUN mix local.hex --force

WORKDIR "${WORKSPACE_PATH}"

CMD ["zsh"]
