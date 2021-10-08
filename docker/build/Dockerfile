ARG TAG=buster

FROM debian:${TAG}

ENV TAG=${TAG}

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

ENV PATH="${CONTAINER_BIN_PATH}":"${CONTAINER_HOME}"/.local/bin:${PATH}

USER root

# Debian Base
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
    procps \
    inotify-tools \
    # python3 \
    # python3-pip \
    git && \

  apt -y -f install && \

  printf "fs.inotify.max_user_watches=524288\n" > /etc/sysctl.d/01-inotify.conf && \

  useradd -m -u "${CONTAINER_UID}" -s "/bin/bash" "${CONTAINER_USER_NAME}" && \
  su "${CONTAINER_USER_NAME}" -c "sh -c 'mkdir -p ${CONTAINER_BIN_PATH}'" && \
  su "${CONTAINER_USER_NAME}" -c "sh -c 'mkdir -p ${WORKSPACE_PATH}'" && \

  find /usr -type d -name doc | xargs rm -rf && \
  find /usr -type d -name examples | xargs rm -rf


# ERLANG BASE
ARG ERLANG_VERSION=OTP-24.1.1
ENV DOCKER_ERLANG_VERSION=${ERLANG_VERSION}
# ENV INSTALL_BUILD_DEPENDENCIES="autoconf dpkg-dev gcc g++ make libncurses5-dev unixodbc-dev libssl-dev libsctp-dev libwxgtk3.0-dev default-jdk fop libxml2-utils xsltproc"
# ENV REMOVE_BUILD_DEPENDENCIES="autoconf libncurses5-dev unixodbc-dev libssl-dev libsctp-dev libwxgtk3.0-dev default-jdk fop libxml2-utils xsltproc"
# ENV RUNTIME_DEPENDENCIES="libcanberra-gtk-module procps libncurses5 libwxbase3.0-0v5 libwxgtk3.0-0v5 libodbc1 libssl1.1 libsctp1 man"
ENV INSTALL_BUILD_DEPENDENCIES="autoconf dpkg-dev gcc g++ make libncurses-dev unixodbc-dev libssl-dev libsctp-dev"
ENV REMOVE_BUILD_DEPENDENCIES="autoconf libncurses-dev unixodbc-dev libssl-dev libsctp-dev"
ENV RUNTIME_DEPENDENCIES="libodbc1 libssl1.1 libsctp1 man"
RUN \
  apt -y -q install --no-install-recommends ${INSTALL_BUILD_DEPENDENCIES} ${RUNTIME_DEPENDENCIES} && \

  # INSTALL ERLANG
  git clone --depth 1 --branch "${ERLANG_VERSION}" https://github.com/erlang/otp.git OTP && \
  ls

RUN \
  cd OTP && \
  export ERL_TOP="${PWD}" && \
  ./otp_build autoconf && \
  gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
  ./configure --build="$gnuArch" && \
  make -j$(nproc) && \
  make install && \
  cd - && \
  rm -rf OTP && \

  # SMOKE TEST
  erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().'  -noshell && \
  erl -eval 'io:fwrite("~1p~n", [lists:sort(erlang:loaded())]), halt().'  -noshell

# REBAR3
ARG REBAR3_VERSION=3.17.0
ENV DOCKER_REBAR3_VERSION=${DOCKER_REBAR3_VERSION}
RUN \
  # DOWNLOAD REBAR3 FROM A GITHUB BRANCH OR TAG
  git clone --depth 1 --branch "${REBAR3_VERSION}" https://github.com/erlang/rebar3.git && \

  # INSTALL REBAR3
  cd rebar3 && \
  ./bootstrap && \
  mv rebar3 ~/bin && \
  cd - && \
  rm -rf rebar3

# ELIXIR BASE
ARG ELIXIR_VERSION=1.12.3
ENV DOCKER_ELIXIR_VERSION=${ELIXIR_VERSION}
RUN apt -y install make && \

  # DOWNLOAD ELIXIR FROM A GITHUB BRANCH OR TAG
  git clone --depth 1 --branch "${ELIXIR_VERSION}" https://github.com/elixir-lang/elixir.git && \

  # INSTALL ELIXIR
  cd elixir && \
  make clean test && \
  make install clean && \
  cd - && \

  # CLEANUP
  rm -rf elixir

RUN \
  apt -y auto-remove ${REMOVE_BUILD_DEPENDENCIES} && \
  apt auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

RUN mkdir -p ~/.config ~/.local ~/.cache && ls -al ~

WORKDIR "${WORKSPACE_PATH}"

CMD ["zsh"]
