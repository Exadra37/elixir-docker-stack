ARG OS_TAG=latest

# FROM exadra37/debian-dev:${OS_TAG}
FROM debian:${OS_TAG}

ARG DOCKER_ERLANG_VERSION=22.0
ARG DISPLAY=":0"
ARG ERLANG_DOWNLOAD_URL=https://packages.erlang-solutions.com/erlang/esl-erlang/FLAVOUR_1_general/esl-erlang_"${DOCKER_ERLANG_VERSION}"-1~debian~stretch_amd64.deb

ENV DOCKER_BUILD=/docker-build
ARG DOCKER_BUILD_SCRIPTS_RELEASE=dev-wip
ARG DOCKER_BUILD_SCRIPTS_URL=https://gitlab.com/exadra37-bash/docker/bash-scripts-for-docker-builds/-/archive/"${DOCKER_BUILD_SCRIPTS_RELEASE}"/bash-scripts-for-docker-builds-dev.tar.gz?path=scripts

ARG HOST_USER_NAME="developer"
ARG HOST_UID="1000"
ARG HOST_GID="1000"
ARG OH_MY_ZSH_THEME="amuse"

ENV HOST_USER_NAME=${HOST_USER_NAME} \
    HOST_HOME=/home/${HOST_USER_NAME} \
    HOST_UID=${HOST_UID} \
    HOST_GID=${HOST_GID}

ENV WORKSPACE_PATH=${HOST_HOME}/workspace

ENV DISPLAY=${DISPLAY}

ENV PATH="${HOST_HOME}"/.local/bin:${PATH}


##############
# HOST USER
##############

USER root

RUN groupadd -g "${HOST_GID}" "${HOST_USER_NAME}" && \
    useradd --create-home --uid "${HOST_UID}" --gid "${HOST_GID}" "${HOST_USER_NAME}"
RUN mkdir -p "${HOST_HOME}"/.config "${HOST_HOME}"/.local/{bin,share} "${HOST_HOME}"/.cache
RUN chown -R "${HOST_USER_NAME}":"${HOST_USER_NAME}" "${HOST_HOME}"


##############
# ERLANG
##############

RUN apt update && \
  apt -y upgrade && \
  apt -y -q install --no-install-recommends \
    build-essential \
    less \
    libcanberra-gtk-module \
    procps \
    libncurses5

# RUN apt -y -q install --no-install-recommends \
#     libwxgtk3.2-dev \
#     libsctp1
# @link https://github.com/elixir-desktop/desktop/blob/main/guides/getting_started.md#gnulinux
RUN apt -y -q install --no-install-recommends \
   inotify-tools \
   libtool \
   automake \
   libgmp-dev \
   make \
   libssl-dev \
   libncurses5-dev \
   curl \
   git

RUN apt -y -q install --no-install-recommends libwxgtk3.2-dev
RUN apt -y -q install --no-install-recommends ca-certificates
RUN apt -y -q install --no-install-recommends libssl1.1

ENV ERLANG_DOWNLOAD_URL=https://binaries2.erlang-solutions.com/debian/pool/contrib/e/esl-erlang/esl-erlang_${DOCKER_ERLANG_VERSION}-1~debian~buster_amd64.deb

RUN curl -fsSL -o esl.deb "${ERLANG_DOWNLOAD_URL}" && \
    dpkg -i esl.deb && \
    rm -f esl.deb


###################
# DOCKER SCRIPTS
###################

RUN echo "DOCKER_BUILD_SCRIPTS_URL: ${DOCKER_BUILD_SCRIPTS_URL}"
RUN curl \
    -fsSl \
    -o archive.tar.gz \
    ${DOCKER_BUILD_SCRIPTS_URL} && \

  tar xf archive.tar.gz -C "${DOCKER_BUILD}" --strip 1 && \

  rm -vf archive.tar.gz

USER "${CONTAINER_USER_NAME}"

WORKDIR "${WORKSPACE_PATH}"

CMD ["erl"]
