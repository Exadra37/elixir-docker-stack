ARG OS_TAG=latest

FROM exadra37/debian-dev:${OS_TAG}

ARG DOCKER_ERLANG_VERSION=23.0.2
ENV DOCKER_ERLANG_VERSION=${DOCKER_ERLANG_VERSION}

ARG DOCKER_REBAR3_VERSION=3.13.2
ENV DOCKER_REBAR3_VERSION=${DOCKER_REBAR3_VERSION}

ARG DOCKER_DOCSH_VERSION=0.7.2
ENV DOCKER_DOCSH_VERSION=${DOCKER_DOCSH_VERSION}

ARG DISPLAY=":0"
ENV DISPLAY=${DISPLAY}

USER root

RUN \
  apt update && \
  apt -y upgrade && \

  "${DOCKER_BUILD}"/scripts/erlang/install-erlang-from-git-branch.bash \
    "${DOCKER_ERLANG_VERSION}" && \

  find /usr -type d -name doc | xargs rm -rf && \

  apt -y auto-remove && \
  apt clean && \
  rm -rf /var/lib/apt/lists/*

USER "${CONTAINER_USER_NAME}"

WORKDIR "${WORKSPACE_PATH}"

RUN \
  "${DOCKER_BUILD}"/scripts/erlang/rebar/install-rebar3-from-git-branch.sh \
    "${DOCKER_REBAR3_VERSION}"
  # "${DOCKER_BUILD}"/scripts/erlang/docsh/install-docsh-from-git-branch.sh \
    # "${DOCKER_DOCSH_VERSION}"

CMD ["erl"]
