FROM elixir:alpine

ARG CONTAINER_USER="elixir"
ARG CONTAINER_UID="1000"
ARG CONTAINER_GID="1000"
ARG DISPLAY=":0"
ARG OH_MY_ZSH_THEME="bira"

ENV CONTAINER_USER=${CONTAINER_USER} \
    CONTAINER_UID=${CONTAINER_UID} \
    CONTAINER_GID=${CONTAINER_GID} \
    DISPLAY=${DISPLAY}

 #   ln -s /usr/bin/python3 /usr/bin/python && \

RUN apk add --no-cache \
        curl \
        git \
        zsh \
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
        chromium \
        ttf-freefont \
        libcanberra-gtk3 \
        mesa-gl \
        mesa-dri-intel \
        dbus-x11 && \

    pip install psycopg2 && \
    # apk add --no-cache --virtual \
    #     .build-deps \
    #     gcc \
    #     musl-dev \
    #     postgresql-dev && \

    pip install pgcli && \

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

    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)" && \

    cp -v /root/.zshrc /home/"${CONTAINER_USER}"/.zshrc && \
        cp -rv /root/.oh-my-zsh /home/"${CONTAINER_USER}"/.oh-my-zsh && \
        sed -i "s/\/root/\/home\/${CONTAINER_USER}/g" /home/"${CONTAINER_USER}"/.zshrc && \
        sed -i s/ZSH_THEME=\"robbyrussell\"/ZSH_THEME=\"${OH_MY_ZSH_THEME}\"/g /home/${CONTAINER_USER}/.zshrc && \
        mkdir /home/"${CONTAINER_USER}"/workspace && \
        chown -R "${CONTAINER_USER}":"${CONTAINER_USER}" /home/"${CONTAINER_USER}"

ENV PGDATA=/var/lib/postgresql/data

RUN mkdir -p "${PGDATA}" /run/postgresql && \
    ls -al "${PGDATA}/.." && \
    chown -R "${CONTAINER_USER}":"${CONTAINER_USER}" "${PGDATA}/.." && \
    chown -R "${CONTAINER_USER}":"${CONTAINER_USER}" /run/postgresql/ && \
    #chmod -R 0700 "${PGDATA}/.." && \
    addgroup "${CONTAINER_USER}" postgres

USER "${CONTAINER_USER}"

RUN zsh -c "eval 'initdb --username=postgres --pwfile=<(echo postgres)'" && \
    ls -al $PGDATA && \

    # https://docs.docker.com/engine/examples/postgresql_service/
    # Create a PostgreSQL role named ``docker`` with ``docker`` as the password and
    # then create a database `docker` owned by the ``docker`` role.
    # Note: here we use ``&&\`` to run commands one after the other - the ``\``
    #       allows the RUN command to span multiple lines.
    pg_ctl start && \
    createdb --username postgres -O postgres testapp_dev

VOLUME  ["/var/log/postgresql", "/var/lib/postgresql"]

# This commands will run under user defined above
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix archive.install --force hex phx_new

EXPOSE 5432

WORKDIR "/home/${CONTAINER_USER}/workspace"

CMD ["elixir"]
