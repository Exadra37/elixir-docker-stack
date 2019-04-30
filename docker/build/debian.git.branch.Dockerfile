FROM debian:stretch

ARG DOCKER_ERLANG_VERSION=21.3.4
ARG DOCKER_ELIXIR_VERSION=1.8.1
ARG ELIXIR_GIT_BRANCH="${DOCKER_ELIXIR_VERSION}"

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

ENV OTP_VERSION="${DOCKER_ERLANG_VERSION}"

ARG OTP_DOWNLOAD_URL="https://github.com/erlang/otp/archive/OTP-${OTP_VERSION}.tar.gz"
ARG OTP_DOWNLOAD_SHA256="1af7c01e80d04423c14449fcb7c5f3b11e0375fe42d01b088ccef4cbcb733c3a"

ARG ELIXIR_INSTALL_DIR=/usr/local/src/elixir
ARG ELIXIR_BIN_PATH="${ELIXIR_INSTALL_DIR}/bin"

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

ENV PATH="${ELIXIR_BIN_PATH}":"${CONTAINER_BIN_PATH}":"${POSTGRES_BIN_PATH}":"${PATH}"

ARG BUILD_DEPS=' \
  autoconf \
  dpkg-dev \
  gcc \
  g++ \
  make \
  libncurses-dev \
  unixodbc-dev \
  libssl-dev \
  libsctp-dev \
  unixodbc-dev \
  libwxgtk3.0-dev \
'

COPY ./resources /docker-build-resources

# We'll install the build dependencies, and purge them on the last step to make
# sure our final image contains only what we've just built:
RUN \
  fetchDeps=' \
    build-essential \
    curl \
    zsh \
    git \
    libcanberra-gtk-module \
    ca-certificates' \
  && runtimeDeps=' \
    procps \
    libncurses5 \
    libwxbase3.0-0v5 \
    libwxgtk3.0-0v5 \
    libodbc1 \
    libssl1.1 \
    libsctp1 \
  ' \
  && apt update \
  && apt install -y -q --no-install-recommends \
    $fetchDeps \
    $runtimeDeps \
    $BUILD_DEPS && \

  useradd -m -u "${CONTAINER_UID}" -s /usr/bin/zsh "${CONTAINER_USER_NAME}" && \

  chown --recursive "${CONTAINER_USER_NAME}":"${CONTAINER_USER_NAME}" "${RESOURCES_DIR}" && \

  su "${CONTAINER_USER_NAME}" -c "sh -c 'mkdir -p ${CONTAINER_BIN_PATH}'" && \
  su "${CONTAINER_USER_NAME}" -c "sh -c 'cp -r ${RESOURCES_DIR}/scripts/elixir/bin/* ${CONTAINER_BIN_PATH}'" && \

  "${RESOURCES_DIR}"/scripts/debian/install-locales.sh \
    "${LOCALIZATION}" \
    "${ENCODING}" && \

  "${RESOURCES_DIR}"/scripts/debian/install-nodejs.sh "${NODE_VERSION}" && \

  "${RESOURCES_DIR}"/scripts/debian/install-pgcli.sh && \

  "${RESOURCES_DIR}"/scripts/debian/install-inotify-tools.sh && \

  "${RESOURCES_DIR}"/scripts/install-oh-my-zsh.sh \
    "${CONTAINER_HOME}" \
    "${OH_MY_ZSH_THEME}" && \

  "${RESOURCES_DIR}"/scripts/create-workspace-dir.sh \
    "${WORKSPACE_PATH}" \
    "${CONTAINER_USER_NAME}" && \

  printf "\nOPT_DOWNLOAD_URL: ${OTP_DOWNLOAD_URL}\n" && \

  curl -fSL -o otp-src.tar.gz "$OTP_DOWNLOAD_URL" && \
  #echo "$OTP_DOWNLOAD_SHA256  otp-src.tar.gz" | sha256sum -c - && \
  export ERL_TOP="/usr/src/otp_src_${OTP_VERSION%%@*}" && \
  mkdir -vp $ERL_TOP && \
  tar -xzf otp-src.tar.gz -C $ERL_TOP --strip-components=1 && \
  rm otp-src.tar.gz && \
  ( cd $ERL_TOP && \
    ./otp_build autoconf && \
    gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" && \
    ./configure --build="$gnuArch" && \
    make -j$(nproc) && \
    make install ) && \
  find /usr/local -name examples | xargs rm -rf && \
  rm -rf $ERL_TOP

RUN \
  printf "\ELIXIR_INSTALL_DIR: ${ELIXIR_INSTALL_DIR}\n" && \
  printf "\ELIXIR_GIT_BRANCH: ${ELIXIR_GIT_BRANCH}\n" && \

  mkdir -p "${ELIXIR_INSTALL_DIR}" && \
  cd "${ELIXIR_INSTALL_DIR}" && \
  git clone --branch "${ELIXIR_GIT_BRANCH}" https://github.com/elixir-lang/elixir.git . && \
  make clean test && \

  # CLEANUP
  apt-get purge -y --auto-remove $BUILD_DEPS && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${CONTAINER_HOME}"

RUN "${RESOURCES_DIR}"/scripts/elixir/phoenix/install.sh "${PHOENIX_VERSION}"

VOLUME ["/var/log/postgresql", "/var/lib/postgresql", "/home/elixir/.config/sublime-text-3"]

WORKDIR "${WORKSPACE_PATH}"

CMD ["elixir"]
