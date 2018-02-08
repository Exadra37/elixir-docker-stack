FROM elixir:1.4

ARG CONTAINER_USER="elixir"
ARG LANGUAGE_CODE="en"
ARG COUNTRY_CODE="GB"
ARG ENCODING="UTF-8"

ARG LOCALE_STRING="${LANGUAGE_CODE}_${COUNTRY_CODE}"
ARG LOCALIZATION="${LOCALE_STRING}.${ENCODING}"

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install \
        locales \
        inotify-tools && \
    apt-get -y -f install && \

    # Locales
    echo "${LOCALIZATION} ${ENCODING}" > /etc/locale.gen && \
    locale-gen "${LOCALIZATION}" && \

    useradd -m -u 1000 -s /usr/bin/bash "${CONTAINER_USER}"

USER "${CONTAINER_USER}"

ENV LANG "${LOCALIZATION}"
ENV LANGUAGE "${LOCALE_STRING}:${LANGUAGE_CODE}"
ENV LC_ALL "${LOCALIZATION}"

# Set the work dir for the container user defined above
WORKDIR /home/elixir/workspace

# This commands will run under user defined above
RUN mix local.hex --force && \
    mix local.rebar --force

CMD ["elixir"]
