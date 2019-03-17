FROM elixir:alpine

ARG CONTAINER_USER="elixir"
ARG CONTAINER_UID="1000"
ARG CONTAINER_GID="1000"
ARG DISPLAY=":0"
ARG OH_MY_ZSH_THEME="bira"

ENV CONTAINER_USER=${CONTAINER_USER} \
  CONTAINER_UID=${CONTAINER_UID} \
  CONTAINER_GID=${CONTAINER_GID} \
  DISPLAY=${DISPLAY} \
  PGDATA=/var/lib/postgresql/data

RUN apk update && \
  apk upgrade && \
  apk add --no-cache \
    ca-certificates \
    curl \
    git \
    zsh \
    firefox-esr \
    python \
    python-dev \
    py-pip \
    nodejs \
    npm \
    postgresql \
    postgresql-client \
    postgresql-contrib \
    postgresql-libs \
    postgresql-dev \
    gcc \
    musl-dev \
    inotify-tools \
    ttf-freefont \
    libcanberra-gtk3 \
    mesa-gl \
    mesa-dri-intel \
    dbus \
    erlang-xmerl \
    erlang-dialyzer \
    erlang-sasl \
    erlang-runtime-tools \
    erlang-ssh \
    erlang-erl-docgen \
    erlang-eunit \
    erlang-inets \
    erlang-tools \
    erlang-snmp \
    erlang-et \
    erlang-dev \
    erlang-wx \
    erlang-debugger \
    erlang-jinterface \
    erlang-asn1 \
    erlang-hipe \
    erlang-odbc \
    erlang-otp-mibs \
    erlang-reltool \
    erlang-crypto \
    erlang-common-test \
    erlang-ssl \
    erlang-mnesia \
    erlang-os-mon \
    erlang-erts \
    erlang-public-key \
    erlang-observer \
    erlang-edoc \
    erlang-eldap \
    erlang-megaco \
    erlang-diameter \
    erlang-wx && \

  rm -rvf /usr/local/lib/erlang/lib/wx-1.8.6 && \
  ln -s /usr/lib/erlang/lib/wx-1.8.6 /usr/local/lib/erlang/lib && \

  pip install psycopg2 pgcli && \

  printf "fs.inotify.max_user_watches=524288\n" > /etc/sysctl.d/01-exadra37.conf && \

  addgroup \
    -g "${CONTAINER_GID}" \
    -S "${CONTAINER_USER}" && \
  adduser \
    -s /bin/zsh \
    -u "${CONTAINER_UID}" \
    -G  "${CONTAINER_USER}" \
    -h /home/"${CONTAINER_USER}" \
    -D "${CONTAINER_USER}" && \

  mkdir -p "${PGDATA}" /run/postgresql && \
  chown -R "${CONTAINER_USER}":"${CONTAINER_USER}" "${PGDATA}/.." && \
  chown -R "${CONTAINER_USER}":"${CONTAINER_USER}" /run/postgresql/ && \
  addgroup "${CONTAINER_USER}" postgres && \

  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \
  cp -v /root/.zshrc /home/"${CONTAINER_USER}"/.zshrc && \
  cp -rv /root/.oh-my-zsh /home/"${CONTAINER_USER}"/.oh-my-zsh && \
  sed -i "s/\/root/\/home\/${CONTAINER_USER}/g" /home/"${CONTAINER_USER}"/.zshrc && \
  sed -i s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"${OH_MY_ZSH_THEME}\"/g /home/${CONTAINER_USER}/.zshrc && \

  mkdir /home/"${CONTAINER_USER}"/workspace && \
  chown -R "${CONTAINER_USER}":"${CONTAINER_USER}" /home/"${CONTAINER_USER}"

USER "${CONTAINER_USER}"

# This commands will run under user defined above
RUN zsh -c "eval 'initdb --username=postgres --pwfile=<(echo postgres)'" && \

  # https://docs.docker.com/engine/examples/postgresql_service/
  pg_ctl start && \
  createdb --username postgres --owner postgres testapp_dev && \
  createdb --username postgres --owner postgres testapp_test && \
  createdb --username postgres --owner postgres testapp_prod && \

  mix local.hex --force && \
  mix local.rebar --force && \
  mix archive.install --force hex phx_new

VOLUME ["/var/log/postgresql", "/var/lib/postgresql"]

EXPOSE 5432

WORKDIR "/home/${CONTAINER_USER}/workspace"

CMD ["elixir"]
